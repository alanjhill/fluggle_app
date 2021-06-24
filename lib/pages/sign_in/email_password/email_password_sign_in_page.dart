part of email_password_sign_in_ui;

class EmailPasswordSignInPage extends StatefulWidget {
  const EmailPasswordSignInPage({Key? key, required this.model, this.onSignedIn}) : super(key: key);
  final EmailPasswordSignInModel model;
  final VoidCallback? onSignedIn;

  factory EmailPasswordSignInPage.withFirebaseAuth(FirebaseAuth auth, {VoidCallback? onSignedIn}) {
    return EmailPasswordSignInPage(
      model: EmailPasswordSignInModel(auth: auth),
      onSignedIn: onSignedIn,
    );
  }

  @override
  _EmailPasswordSignInPageState createState() => _EmailPasswordSignInPageState();
}

class _EmailPasswordSignInPageState extends State<EmailPasswordSignInPage> {
  final FocusScopeNode _node = FocusScopeNode();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  EmailPasswordSignInModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    // Temporary workaround to update state until a replacement for ChangeNotifierProvider is found
    model.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    model.dispose();
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSignInError(EmailPasswordSignInModel model, dynamic exception) {
    showExceptionAlertDialog(
      context: context,
      title: model.errorAlertTitle,
      exception: exception,
    );
  }

  Future<void> _submit() async {
    try {
      final bool success = await model.submit();
      if (success) {
        if (model.formType == EmailPasswordSignInFormType.forgotPassword) {
          await showAlertDialog(
            context: context,
            title: EmailPasswordSignInStrings.resetLinkSentTitle,
            content: EmailPasswordSignInStrings.resetLinkSentMessage,
            defaultActionText: EmailPasswordSignInStrings.ok,
          );
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
    _submit();
  }

  void _updateFormType(EmailPasswordSignInFormType formType) {
    model.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      key: const Key('displayName'),
      style: TextStyle(color: Colors.white),
      controller: _displayNameController,
      decoration: InputDecoration(
        labelText: EmailPasswordSignInStrings.displayNameLabel,
        hintText: EmailPasswordSignInStrings.displayNameHint,
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
      style: TextStyle(color: Colors.white),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: EmailPasswordSignInStrings.emailLabel,
        hintText: EmailPasswordSignInStrings.emailHint,
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
      style: TextStyle(color: Colors.white),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: model.passwordLabelText,
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

  Widget _buildContent() {
    return FocusScope(
      node: _node,
      child: Form(
        onChanged: () => model.updateWith(email: _emailController.text, password: _passwordController.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (model.formType == EmailPasswordSignInFormType.register) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildDisplayNameField(),
            ],
            const SizedBox(height: 8.0),
            _buildEmailField(),
            if (model.formType != EmailPasswordSignInFormType.forgotPassword) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildPasswordField(),
            ],
            const SizedBox(height: 8.0),
            FormSubmitButton(
              key: const Key('primary-button'),
              text: model.primaryButtonText,
              loading: model.isLoading,
              onPressed: model.isLoading ? null : _submit,
            ),
            const SizedBox(height: 8.0),
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
        title: Text(model.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              width: min(constraints.maxWidth, 600),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2.0,
                color: kFlugglePrimaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
