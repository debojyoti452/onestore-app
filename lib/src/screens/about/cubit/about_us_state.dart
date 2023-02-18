part of 'about_us_cubit.dart';

class AboutUsState extends Equatable {
  const AboutUsState({
    required this.status,
    this.appVersion = '',
  });

  final AppCubitStatus status;
  final String? appVersion;

  @override
  List<Object?> get props => [
        status,
        appVersion,
      ];
}
