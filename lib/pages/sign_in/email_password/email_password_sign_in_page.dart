part of email_password_sign_in_ui;

class EmailPasswordSignInPage extends ConsumerStatefulWidget {
  const EmailPasswordSignInPage({Key? key, required this.model, this.onSignedIn}) : super(key: key);
  final EmailPasswordSignInModel model;
  final VoidCallback? onSignedIn;

  factory EmailPasswordSignInPage.withFirebaseAuth(FirebaseAuth auth, {VoidCallback? onSignedIn}) {
    return EmailPasswordSignInPage(
      model: EmailPasswordSignInModel(auth: auth),
      onSignedIn: onSignedIn,
    );
  }

  factory EmailPasswordSignInPage.updateUser(FirebaseAuth auth, {VoidCallback? onSignedIn}) {
    debugPrint('auth.currentUser: ${auth.currentUser}');
    String? displayName = auth.currentUser!.displayName;
    String? email = auth.currentUser!.email;
    return EmailPasswordSignInPage(
      model: EmailPasswordSignInModel(
        auth: auth,
        displayName: displayName ?? '',
        email: email!,
        formType: EmailPasswordSignInFormType.updateAccount,
      ),
    );
  }

  @override
  _EmailPasswordSignInPageState createState() => _EmailPasswordSignInPageState();
}

class _EmailPasswordSignInPageState extends ConsumerState<EmailPasswordSignInPage> {
  final FocusScopeNode _node = FocusScopeNode();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  EmailPasswordSignInModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    // Temporary workaround to update state until a replacement for ChangeNotifierProvider is found
    model.addListener(() => setState(() {}));
    _displayNameController.text = model.displayName;
    _emailController.text = model.email;
  }

  @override
  void dispose() {
    model.dispose();
    _node.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _showSignInError(EmailPasswordSignInModel model, dynamic exception) {
    showExceptionAlertDialog(
      context: context,
      title: model.errorAlertTitle,
      exception: exception,
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final userService = ref.read(userServiceProvider);

    try {
      final bool success = await model.submit();

      debugPrint('${model.auth.currentUser}');

      if (success) {
        if (model.formType == EmailPasswordSignInFormType.register) {
          // Create Firestore User
          await userService.createUser(ref, user: model.auth.currentUser!);

          // Navigate to the previous page
          Navigator.of(context).pop();
        } else if (model.formType == EmailPasswordSignInFormType.forgotPassword) {
          await showAlertDialog(
            context: context,
            title: EmailPasswordSignInStrings.resetLinkSentTitle,
            content: EmailPasswordSignInStrings.resetLinkSentMessage,
            defaultActionText: EmailPasswordSignInStrings.ok,
          );
        } else if (model.formType == EmailPasswordSignInFormType.updateAccount) {
          // Update Firestore User
          await userService.updateUser(ref, user: model.auth.currentUser!);

          // Show Alert
          await showAlertDialog(
            context: context,
            title: EmailPasswordSignInStrings.updateAccountSuccessTitle,
            content: EmailPasswordSignInStrings.updateAccountSuccessMessage,
            defaultActionText: EmailPasswordSignInStrings.ok,
          );
          setState(() {
            model.isLoading = false;
          });
        } else {
          if (widget.onSignedIn != null) {
            widget.onSignedIn?.call();
          }
        }
      }
    } catch (e) {
      _showSignInError(model, e);
    }
  }

  void _displayNameEditingComplete() {
    if (model.canSubmitDisplayName) {
      _node.nextFocus();
    }
  }

  void _emailEditingComplete() {
    if (model.canSubmitEmail) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!model.canSubmitEmail) {
      _node.previousFocus();
      return;
    }
    //_submit();
  }

  void _passwordConfirmEditingComplete() {
    if (!model.canSubmitEmail) {
      _node.previousFocus();
      return;
    }
    //_submit();
  }

  void _updateFormType(EmailPasswordSignInFormType formType) {
    model.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      key: const Key('displayName'),
      style: const TextStyle(color: Colors.white),
      controller: _displayNameController,
      decoration: InputDecoration(
        labelText: EmailPasswordSignInStrings.displayNameLabel,
        hintText: EmailPasswordSignInStrings.displayNameHint,
        hintStyle: const TextStyle(color: Colors.blueGrey),
        errorText: model.displayNameErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      //keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _displayNameEditingComplete,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      key: const Key('email'),
      style: const TextStyle(color: Colors.white),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: EmailPasswordSignInStrings.emailLabel,
        //labelStyle: TextStyle(color: kFluggleLightColor),
        hintText: EmailPasswordSignInStrings.emailHint,
        hintStyle: const TextStyle(color: Colors.blueGrey),
        errorText: model.emailErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _emailEditingComplete,
      inputFormatters: <TextInputFormatter>[
        model.emailInputFormatter,
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: const Key('password'),
      style: const TextStyle(color: Colors.white),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: model.passwordLabelText,
        //labelStyle: TextStyle(color: kFluggleLightColor),
        errorText: model.passwordErrorText,
        enabled: !model.isLoading,
      ),
      obscureText: true,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _passwordEditingComplete,
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      key: const Key('passwordConfirm'),
      style: const TextStyle(color: Colors.white),
      controller: _passwordConfirmController,
      decoration: InputDecoration(
        labelText: model.passwordConfirmLabelText,
        errorText: model.passwordConfirmErrorText,
        enabled: !model.isLoading,
      ),
      obscureText: true,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _passwordConfirmEditingComplete,
/*      validator: (value) {
        if (value != _passwordConfirmController.text) {
          return 'Passwords do not match';
        }
      },*/
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return FocusScope(
      node: _node,
      child: Form(
        onChanged: () => model.updateWith(
            displayName: _displayNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            passwordConfirm: _passwordConfirmController.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display Name
            if (model.formType == EmailPasswordSignInFormType.register || model.formType == EmailPasswordSignInFormType.updateAccount) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildDisplayNameField(),
            ],
            const SizedBox(height: 8.0),
            // Email
            _buildEmailField(),
            // Password
            if (model.formType != EmailPasswordSignInFormType.forgotPassword) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildPasswordField(),
            ],
            // Password Confirm
            if (model.formType == EmailPasswordSignInFormType.register || model.formType == EmailPasswordSignInFormType.updateAccount) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildPasswordConfirmField(),
            ],
            const SizedBox(height: 8.0),
            FormSubmitButton(
              key: const Key('primary-button'),
              text: model.primaryButtonText,
              loading: model.isLoading,
              onPressed: model.isLoading ? null : () => _submit(context, ref),
            ),
            const SizedBox(height: 8.0),
            if (model.formType == EmailPasswordSignInFormType.signIn)
              TextButton(
                key: const Key('secondary-button'),
                child: Text(model.secondaryButtonText),
                onPressed: model.isLoading ? null : () => _updateFormType(model.secondaryActionFormType),
              ),
            if (model.formType == EmailPasswordSignInFormType.signIn)
              TextButton(
                key: const Key('tertiary-button'),
                child: const Text(EmailPasswordSignInStrings.forgotPasswordQuestion),
                onPressed: model.isLoading ? null : () => _updateFormType(EmailPasswordSignInFormType.forgotPassword),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        titleText: model.title,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              width: min(constraints.maxWidth, 600),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2.0,
                color: kFluggleDarkColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(context, ref),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
