import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController name= TextEditingController();
  TextEditingController age= TextEditingController();
  TextEditingController city= TextEditingController();
  TextEditingController university= TextEditingController();

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: const Text('Profile Info', style: TextStyle(color: Colors.white))
      ),
      body: Center(
        child: Column(
      mainAxisSize :MainAxisSize.min,
      children:[
        TextField(
          controller: name,
         decoration: InputDecoration(
           hintText: 'Enter your name',
           labelText: 'your name',
           border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
           suffixIcon: IconButton(
             onPressed: (){
               name.clear();
             },
             icon: Icon(Icons.close),
           ),
         ),
        ),
        SizedBox(height:20),
        TextField(
          controller: age,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your age',
            labelText: 'your age',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            suffixIcon: IconButton(
              onPressed: (){
                age.clear();
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
        SizedBox(height:20),
        TextField(
          controller: city,
          decoration: InputDecoration(
            hintText: 'Enter your city',
            labelText: 'your city',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            suffixIcon: IconButton(
              onPressed: (){
                city.clear();
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
        SizedBox(height:20),
        TextField(
          controller: university,
          decoration: InputDecoration(
            hintText: 'Enter your university name',
            labelText: 'your university',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            suffixIcon: IconButton(
              onPressed: (){
                university.clear();
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
        const SizedBox(height: 60),


      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600,
                  foregroundColor: Colors.white,
                  padding:EdgeInsets.symmetric(horizontal:20, vertical:10),
                  elevation: 5,
                  fixedSize: Size(110, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
              ),
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:  Text('About me clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                );
              },
              child: const Text('About Me')
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade600,
              foregroundColor: Colors.white,
              padding:EdgeInsets.symmetric(horizontal:20, vertical:10),
                elevation: 5,
                fixedSize: Size(110, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )
            ),
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contact clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                );
              },
              child: const Text('Contact')
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade600,
                foregroundColor: Colors.white,
                padding:EdgeInsets.symmetric(horizontal:20, vertical:10),
                elevation: 5,
                fixedSize: Size(110, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
            ),
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text('Skills clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                );
              },
              child: const Text('Skills'),
          ),

        ]
      )

    ],
        ),
      ),
    );

  }
}
