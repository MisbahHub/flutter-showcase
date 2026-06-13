import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController email= TextEditingController();
  TextEditingController password= TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isHidden=true;
  FocusNode passwordFocus = FocusNode();


  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            SizedBox(height:100),
            Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Microsoft_Account_Logo.svg/960px-Microsoft_Account_Logo.svg.png',
            height: 100,
            width: 100,
            ),

            SizedBox(height:20),
            Text('Login Page', textAlign: TextAlign.center , style: TextStyle(fontSize:25, fontWeight: FontWeight.bold)),
            SizedBox(height:10),
            Text(
            'Please enter your email and password to get start with your account',
            style: TextStyle(fontWeight: FontWeight.w300)),
            SizedBox(height:15),

            TextFormField(
              controller : email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (value){
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'email',
                border: OutlineInputBorder(),
                prefixIcon : Icon(Icons.email_outlined),
                suffixIcon : email.text.isNotEmpty
                ?IconButton(
                  onPressed:(){
                    email.clear();
                    setState(() {});
                    },
                  icon : Icon(Icons.clear),
                )
                 : null,
              ),
                validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your email';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(passwordFocus);
              },
            ),

            SizedBox(height:15),
            TextFormField(
              controller: password,
              focusNode: passwordFocus,
              obscureText: isHidden,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              onChanged:(value){
                setState(() {});
              },
              decoration: InputDecoration(
                  hintText: 'password',
                  border :OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isHidden? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: (){
                    setState(() {
                    isHidden =!isHidden;
                    });
                  },
                ),
                ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'please enter your password';
                }
                return null;
              }
            ),

            SizedBox(height:15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:(){
                  if(formkey.currentState!.validate()){

                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(15),
                ),
                child: Text('Login'),
              ),
            ),
            SizedBox(height:10),
            Row(
              mainAxisAlignment : MainAxisAlignment.end,
              children :[
                TextButton(
                    onPressed: (){},
                    child: Text('forgot password?')
                ),
              ],
            ),
            SizedBox(height:20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:(){},
                child: Text("Don't have an account? Sign In"),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                )
              ),
            )
          ]
        ),
      ),
    );
  }
}
