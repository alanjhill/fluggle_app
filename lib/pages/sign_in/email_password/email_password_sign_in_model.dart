part of email_password_sign_in_ui;

enum EmailPasswordSignInFormType { signIn, register, forgotPassword, updateAccount }

class EmailAndPasswordValidators {
  final TextInputFormatter emailInputFormatter = ValidatorInputFormatter(editingValidator: EmailEditingRegexValidator());
  final StringValidator displayNameRegisterSubmitValidator = NonEmptyStringValidator();
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();

  final StringValidator passwordRegisterSubmitValidator = MinLengthStringValidator(8);
  final StringValidator passwordConfirmRegisterSubmitValidator = MinLengthStringValidator(8);

  final StringValidator passwordUpdateSubmitValidator = MinLengthOrEmptyStringValidator(8);
  final StringValidator passwordConfirmUpdateSubmitValidator = MinLengthOrEmptyStringValidator(8);

  final StringValidator passwordSignInSubmitValidator = NonEmptyStringValidator();
}

class EmailPasswordSignInModel with EmailAndPasswordValidators, ChangeNotifier {
  EmailPasswordSignInModel({
    required this.auth,
    this.displayName = '',
    this.email = '',
    this.formType = EmailPasswordSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });
  final FirebaseAuth auth;

  String displayName;
  String email;
  String password = '';
  String passwordConfirm = '';
  EmailPasswordSignInFormType formType;
  bool isLoading;
  bool submitted;

  Future<bool> submit() async {
    try {
      updateWith(submitted: true);
      if (!canSubmit) {
        return false;
      }
      updateWith(isLoading: true);
      switch (formType) {
        case EmailPasswordSignInFormType.register:
          UserCredential userCred = await auth.createUserWithEmailAndPassword(email: email, password: password);
          User? user = userCred.user;
          await user!.reload();
          await user.updateEmail(email);
          await user.updateDisplayName(displayName);
          user = auth.currentUser;
          debugPrint('Created User: $user');
          break;
        case EmailPasswordSignInFormType.signIn:
          await auth.signInWithEmailAndPassword(email: email, password: password);
          break;
        case EmailPasswordSignInFormType.forgotPassword:
          await auth.sendPasswordResetEmail(email: email);
          updateWith(isLoading: false);
          break;
        case EmailPasswordSignInFormType.updateAccount:
          User? user = auth.currentUser;
          user!.reload();
          await user.updateDisplayName(displayName);
          await user.updateEmail(email);
          if (password.isNotEmpty) {
            await user.updatePassword(password);
          }
          debugPrint('Updated User: $user');
          break;
      }
      return true;
    } catch (e) {
      updateWith(isLoading: false);
      print('!!! Exception: $e');
      rethrow;
    }
  }

  //void updateEmail(String email) => updateWith(email: email);

  //void updatePassword(String password) => updateWith(password: password);

  void updateFormType(EmailPasswordSignInFormType formType) {
    updateWith(
      email: '',
      password: '',
      passwordConfirm: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  void updateWith({
    String? displayName,
    String? email,
    String? password,
    String? passwordConfirm,
    EmailPasswordSignInFormType? formType,
    bool? isLoading,
    bool? submitted,
  }) {
    this.displayName = displayName ?? this.displayName;
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.passwordConfirm = passwordConfirm ?? this.passwordConfirm;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }

  String get passwordLabelText {
    if (formType == EmailPasswordSignInFormType.register || formType == EmailPasswordSignInFormType.updateAccount) {
      return EmailPasswordSignInStrings.password8CharactersLabel;
    }
    return EmailPasswordSignInStrings.passwordLabel;
  }

  String get passwordConfirmLabelText {
    if (formType == EmailPasswordSignInFormType.register || formType == EmailPasswordSignInFormType.updateAccount) {
      return EmailPasswordSignInStrings.passwordConfirmLabel;
    }
    return EmailPasswordSignInStrings.passwordConfirmLabel;
  }

  // Getters
  String get primaryButtonText {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInStrings.createAnAccount,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.signIn,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInStrings.sendResetLink,
      EmailPasswordSignInFormType.updateAccount: EmailPasswordSignInStrings.updateAccount,
    }[formType]!;
  }

  String get secondaryButtonText {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInStrings.haveAnAccount,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.needAnAccount,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInStrings.backToSignIn,
    }[formType]!;
  }

  EmailPasswordSignInFormType get secondaryActionFormType {
    return <EmailPasswordSignInFormType, EmailPasswordSignInFormType>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInFormType.signIn,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInFormType.register,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInFormType.signIn,
    }[formType]!;
  }

  String get errorAlertTitle {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInStrings.registrationFailed,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.signInFailed,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInStrings.passwordResetFailed,
      EmailPasswordSignInFormType.updateAccount: EmailPasswordSignInStrings.updateAccount,
    }[formType]!;
  }

  String get title {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInStrings.register,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.signIn,
      EmailPasswordSignInFormType.forgotPassword: EmailPasswordSignInStrings.forgotPassword,
      EmailPasswordSignInFormType.updateAccount: EmailPasswordSignInStrings.updateAccount,
    }[formType]!;
  }

  bool get canSubmitDisplayName {
    if (formType == EmailPasswordSignInFormType.register) {
      return displayNameRegisterSubmitValidator.isValid(displayName);
    } else if (formType == EmailPasswordSignInFormType.updateAccount) {
      return displayNameRegisterSubmitValidator.isValid(displayName);
    }
    return displayNameRegisterSubmitValidator.isValid(displayName);
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    } else if (formType == EmailPasswordSignInFormType.updateAccount) {
      return passwordUpdateSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  bool get canSubmitPasswordConfirm {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordConfirmRegisterSubmitValidator.isValid(passwordConfirm);
    } else if (formType == EmailPasswordSignInFormType.updateAccount) {
      return passwordConfirmUpdateSubmitValidator.isValid(passwordConfirm);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  bool get canSubmitPasswordAndPasswordConfirm {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordConfirm == password;
    } else if (formType == EmailPasswordSignInFormType.updateAccount) {
      return passwordConfirm == password;
    }
    return passwordConfirm == password;
  }

  bool get canSubmit {
    bool canSubmitFields = false;
    if (formType == EmailPasswordSignInFormType.forgotPassword) {
      canSubmitFields = canSubmitEmail;
    } else if (formType == EmailPasswordSignInFormType.signIn) {
      canSubmitFields = canSubmitEmail && canSubmitPassword;
    } else if (formType == EmailPasswordSignInFormType.register || formType == EmailPasswordSignInFormType.updateAccount) {
      canSubmitFields = canSubmitEmail && canSubmitPassword && canSubmitPasswordConfirm && canSubmitPasswordAndPasswordConfirm;
    }
    return canSubmitFields && !isLoading;
  }

  String? get displayNameErrorText {
    final bool showErrorText = submitted && !canSubmitDisplayName;
    final String errorText = displayName.isEmpty ? EmailPasswordSignInStrings.invalidDisplayNameEmpty : EmailPasswordSignInStrings.invalidDisplayNameErrorText;
    return showErrorText ? errorText : null;
  }

  String? get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    final String errorText = email.isEmpty ? EmailPasswordSignInStrings.invalidEmailEmpty : EmailPasswordSignInStrings.invalidEmailErrorText;
    return showErrorText ? errorText : null;
  }

  String? get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    final String errorText = password.isEmpty ? EmailPasswordSignInStrings.invalidPasswordEmpty : EmailPasswordSignInStrings.invalidPasswordTooShort;
    return showErrorText ? errorText : null;
  }

  String? get passwordConfirmErrorText {
    final bool showErrorText = submitted && (!canSubmitPasswordConfirm || password != passwordConfirm);
    final String errorText = passwordConfirm.isEmpty
        ? EmailPasswordSignInStrings.invalidPasswordEmpty
        : password != passwordConfirm
            ? EmailPasswordSignInStrings.invalidPasswordAndPasswordConfirm
            : EmailPasswordSignInStrings.invalidPasswordTooShort;

    return showErrorText ? errorText : null;
  }

  @override
  String toString() {
    return 'email: $email, password: $password, passwordConfirm: $passwordConfirm, formType: $formType, isLoading: $isLoading, submitted: $submitted';
  }
}
