import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RunComfyService {
  // ──────────────────────────────────────────────
  // YOUR CREDENTIALS – same as arsalan.py
  // ──────────────────────────────────────────────
  static const String userId = "9aa6ad92-7322-4042-8314-e76cd665b33f";
  static const String apiToken = "d2200a1a-a212-4c83-96d8-d82a18b40db7";
  static const String workflowVersionId = "5b7b2904-7a13-44d4-9b42-1b06cf6dff18";
  // your exact workflow
  static const String baseUrl = "https://beta-api.runcomfy.net/prod/api";

  // EXACT SAME HEADERS AS YOUR PYTHON SCRIPT (with proper User-Agent)
  static const Map<String, String> headers = {
    "Authorization": "Bearer $apiToken",
    "Content-Type": "application/json",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Origin": "https://runcomfy.com",
    "Referer": "https://runcomfy.com/",
  };

  // Machine reuse state
  static String? _currentServerId;
  static String? _currentComfyUrl;
  static DateTime? _lastUsed;
  static const int machineTimeoutMinutes = 30; // keep alive 30 minutes

  // ──────────────────────────────────────────────
  // MAIN PUBLIC METHOD
  // ──────────────────────────────────────────────
  static Future<String?> runTryOn({
    required File personImage,
    required File garmentImage,
    required String clothType, // "upper" or "lower"
    required Function(double) onProgress, // 0.0 → 1.0
  }) async {
    try {
      onProgress(0.05);

      // ── Try to reuse existing machine ──
      if (_currentServerId != null && _currentComfyUrl != null) {
        final age = DateTime.now().difference(_lastUsed!);
        if (age.inMinutes < machineTimeoutMinutes) {
          final status = await _checkMachineStatus(_currentServerId!);
          if (status == "Ready") {
            return await _runOnMachine(
              _currentComfyUrl!,
              personImage,
              garmentImage,
              clothType,
              onProgress,
            );
          }
        }
      }

      // ── No valid machine → launch new one ──
      final serverId = await _launchMachine();
      final comfyUrl = await _waitForReady(serverId);
      _currentServerId = serverId;
      _currentComfyUrl = comfyUrl;
      _lastUsed = DateTime.now();

      return await _runOnMachine(
          comfyUrl, personImage, garmentImage, clothType, onProgress);
    } catch (e) {
      print("RunComfy Error: $e");
      rethrow;
    }
  }

  // ── Launch a new server ──
  static Future<String> _launchMachine() async {
    final resp = await http.post(
      Uri.parse("$baseUrl/users/$userId/servers"),
      headers: headers,
      body: jsonEncode({
        "workflow_version_id": workflowVersionId,
        "server_type": "medium",
        "estimated_duration": 1800, // 30 minutes
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception("Failed to launch machine: ${resp.body}");
    }

    return jsonDecode(resp.body)["server_id"];
  }

  // ── Wait until server reports Ready ──
  static Future<String> _waitForReady(String serverId) async {
    while (true) {
      final resp = await http.get(
        Uri.parse("$baseUrl/users/$userId/servers/$serverId"),
        headers: headers,
      );

      final json = jsonDecode(resp.body);

      if (json["current_status"] == "Ready") {
        return json["main_service_url"];
      }

      await Future.delayed(const Duration(seconds: 6));
    }
  }

  // ── Check if existing machine is still alive ──
  static Future<String> _checkMachineStatus(String serverId) async {
    try {
      final resp = await http.get(
        Uri.parse("$baseUrl/users/$userId/servers/$serverId"),
        headers: headers,
      );

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body)["current_status"];
      }
    } catch (_) {}

    return "Dead";
  }

  // ── Run workflow on an already ready machine ──
  static Future<String?> _runOnMachine(
    String comfyUrl,
    File person,
    File garment,
    String clothType,
    Function(double) onProgress,
  ) async {
    // Upload images
    final personName = await _upload(comfyUrl, person);
    final garmentName = await _upload(comfyUrl, garment);

    onProgress(0.7);

    // Queue exact same workflow as arsalan.py
    final promptId = await _queueExactWorkflow(
        comfyUrl, personName, garmentName, clothType);

    onProgress(0.8);

    // Poll until node 24 (SaveImage) produces result
    String? resultUrl;

    while (resultUrl == null) {
      await Future.delayed(const Duration(seconds: 6));

      final historyResp =
          await http.get(Uri.parse("$comfyUrl/history/$promptId"));

      if (historyResp.statusCode == 200) {
        final json = jsonDecode(historyResp.body);

        final images = json[promptId]?["outputs"]?["24"]?["images"];

        if (images != null && images.isNotEmpty) {
          final filename = images[0]["filename"];
          resultUrl = "$comfyUrl/view?filename=$filename&type=output";
        }
      }
    }

    _lastUsed = DateTime.now(); // refresh timeout

    onProgress(1.0);

    return resultUrl;
  }

  // ── Upload helper ──
  static Future<String> _upload(String comfyUrl, File file) async {
    final request =
        http.MultipartRequest('POST', Uri.parse("$comfyUrl/upload/image"));

    request.headers.addAll(headers);

    request.fields['type'] = 'input';
    request.fields['overwrite'] = 'true';

    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) throw Exception("Upload failed: $body");

    return jsonDecode(body)["name"];
  }

  // ── EXACT SAME WORKFLOW AS YOUR arsalan.py ──
  static Future<String> _queueExactWorkflow(
    String comfyUrl,
    String person,
    String garment,
    String clothType,
  ) async {
    final workflow = {
      "10": {
        "inputs": {"image": person, "upload": "image"},
        "class_type": "LoadImage",
        "_meta": {"title": "Target Person"}
      },
      "11": {
        "inputs": {"image": garment, "upload": "image"},
        "class_type": "LoadImage",
        "_meta": {"title": "Reference Garment"}
      },
      "12": {
        "inputs": {"catvton_path": "zhengchong/CatVTON"},
        "class_type": "LoadAutoMasker",
        "_meta": {"title": "Load AutoMask Generator"}
      },
      "13": {
        "inputs": {
          "cloth_type": clothType,
          "pipe": ["12", 0],
          "target_image": ["10", 0]
        },
        "class_type": "AutoMasker",
        "_meta": {"title": "Auto Mask Generation"}
      },
      "14": {
        "inputs": {"images": ["13", 1]},
        "class_type": "PreviewImage",
        "_meta": {"title": "Masked Target"}
      },
      "15": {
        "inputs": {"images": ["13", 0]},
        "class_type": "PreviewImage",
        "_meta": {"title": "Binary Mask"}
      },
      "16": {
        "inputs": {
          "seed": 505824879015184,
          "steps": 50,
          "cfg": 2.5,
          "pipe": ["17", 0],
          "target_image": ["10", 0],
          "refer_image": ["11", 0],
          "mask_image": ["13", 0]
        },
        "class_type": "CatVTON",
        "_meta": {"title": "TryOn by CatVTON"}
      },
      "17": {
        "inputs": {
          "sd15_inpaint_path": "runwayml/stable-diffusion-inpainting",
          "catvton_path": "zhengchong/CatVTON",
          "mixed_precision": "bf16"
        },
        "class_type": "LoadCatVTONPipeline",
        "_meta": {"title": "Load CatVTON Pipeline"}
      },
      "24": {
        "inputs": {"filename_prefix": "1152", "images": ["16", 0]},
        "class_type": "SaveImage",
        "_meta": {"title": "Save Image"}
      }
    };

    final resp = await http.post(
      Uri.parse("$comfyUrl/prompt"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": workflow, "client_id": "flutter-app"}),
    );

    if (resp.statusCode != 200) {
      throw Exception("Queue failed: ${resp.body}");
    }

    return jsonDecode(resp.body)["prompt_id"];
  }

  // Optional: call this when app closes to save money
  static Future<void> shutdownIfIdle() async {
    if (_currentServerId != null &&
        DateTime.now().difference(_lastUsed!).inMinutes >=
            machineTimeoutMinutes) {
      await http.delete(
        Uri.parse("$baseUrl/users/$userId/servers/$_currentServerId"),
        headers: headers,
      );

      _currentServerId = null;
      _currentComfyUrl = null;
    }
  }
}

