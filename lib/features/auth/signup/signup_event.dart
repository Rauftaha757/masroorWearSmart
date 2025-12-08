abstract class SignupEvent {}

class SignupButtonPressed extends SignupEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? gender;

  SignupButtonPressed({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.gender,
  });
}
