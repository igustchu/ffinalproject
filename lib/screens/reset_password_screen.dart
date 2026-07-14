import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';



class ResetPasswordScreen extends StatefulWidget {

  const ResetPasswordScreen({super.key});


  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();

}




class _ResetPasswordScreenState
    extends State<ResetPasswordScreen>{


  final supabase =
  Supabase.instance.client;



  final passwordController =
  TextEditingController();


  final confirmPasswordController =
  TextEditingController();



  bool loading=false;


  bool obscurePassword=true;


  bool obscureConfirm=true;






  @override
  void dispose(){

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();

  }








  Future<void> updatePassword() async{


    if(passwordController.text.trim().isEmpty){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Please enter new password"
          ),

        ),

      );


      return;

    }





    if(passwordController.text.trim()
        !=
        confirmPasswordController.text.trim()){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Passwords do not match"
          ),

        ),

      );


      return;

    }





    setState((){

      loading=true;

    });





    try{


      await supabase.auth.updateUser(


        UserAttributes(

          password:
          passwordController.text.trim(),


        ),


      );





      if(mounted){



        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:
            Text(
                "Password updated successfully"
            ),

          ),

        );






        Navigator.pushAndRemoveUntil(


          context,


          MaterialPageRoute(


            builder:(_)=>

            const LoginScreen(),


          ),


              (route)=>false,


        );



      }




    }


    catch(e){



      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(

          content:
          Text(
              e.toString()
          ),

        ),


      );



    }




    finally{


      if(mounted){


        setState((){

          loading=false;

        });


      }


    }



  }









  @override
  Widget build(BuildContext context){


    return Scaffold(



      backgroundColor:
      const Color(0xffD8EEFF),





      body:
      SafeArea(



        child:
        Padding(



          padding:
          const EdgeInsets.all(24),




          child:
          Column(



            crossAxisAlignment:
            CrossAxisAlignment.start,



            children:[




              IconButton(



                padding:
                EdgeInsets.zero,



                icon:
                const Icon(



                  Icons.arrow_back,



                  color:
                  Color(0xff5189C9),



                ),



                onPressed:(){



                  Navigator.pop(context);



                },


              ),






              const SizedBox(height:50),







              Center(



                child:
                Column(



                  children:[




                    const Icon(



                      Icons.lock_reset,



                      size:80,



                      color:
                      Color(0xff5189C9),



                    ),





                    const SizedBox(height:20),





                    const Text(



                      "Set New Password",




                      style:
                      TextStyle(



                        fontSize:26,



                        fontWeight:
                        FontWeight.bold,



                        color:
                        Color(0xff5189C9),



                      ),



                    ),



                  ],



                ),



              ),







              const SizedBox(height:40),








              TextField(



                controller:
                passwordController,



                obscureText:
                obscurePassword,



                decoration:
                InputDecoration(



                  labelText:
                  "New Password",




                  prefixIcon:
                  const Icon(



                    Icons.lock_outline,



                    color:
                    Color(0xff5189C9),



                  ),




                  suffixIcon:
                  IconButton(



                    icon:
                    Icon(



                      obscurePassword

                          ?

                      Icons.visibility

                          :

                      Icons.visibility_off,



                    ),



                    onPressed:(){



                      setState((){



                        obscurePassword =
                        !obscurePassword;



                      });



                    },



                  ),






                  filled:
                  true,



                  fillColor:
                  Colors.white,



                  border:
                  OutlineInputBorder(



                    borderRadius:
                    BorderRadius.circular(20),



                    borderSide:
                    BorderSide.none,



                  ),



                ),



              ),








              const SizedBox(height:16),








              TextField(



                controller:
                confirmPasswordController,



                obscureText:
                obscureConfirm,



                decoration:
                InputDecoration(



                  labelText:
                  "Confirm Password",




                  prefixIcon:
                  const Icon(



                    Icons.lock_outline,



                    color:
                    Color(0xff5189C9),



                  ),





                  suffixIcon:
                  IconButton(



                    icon:
                    Icon(



                      obscureConfirm

                          ?

                      Icons.visibility

                          :

                      Icons.visibility_off,



                    ),



                    onPressed:(){



                      setState((){



                        obscureConfirm =
                        !obscureConfirm;



                      });



                    },



                  ),






                  filled:
                  true,



                  fillColor:
                  Colors.white,



                  border:
                  OutlineInputBorder(



                    borderRadius:
                    BorderRadius.circular(20),



                    borderSide:
                    BorderSide.none,



                  ),



                ),



              ),






              const SizedBox(height:30),







              SizedBox(



                width:
                double.infinity,



                height:55,



                child:
                ElevatedButton(



                  onPressed:
                  loading
                      ?

                  null

                      :

                  updatePassword,





                  style:
                  ElevatedButton.styleFrom(



                    backgroundColor:
                    const Color(0xffffd84d),




                    foregroundColor:
                    const Color(0xff5189C9),



                    elevation:
                    6,



                    shape:
                    RoundedRectangleBorder(



                      borderRadius:
                      BorderRadius.circular(25),



                    ),



                  ),






                  child:
                  loading



                      ?

                  const CircularProgressIndicator(



                    color:
                    Color(0xff5189C9),



                  )



                      :



                  const Text(



                    "Save Password",




                    style:
                    TextStyle(



                      fontSize:18,



                      fontWeight:
                      FontWeight.bold,



                    ),



                  ),



                ),



              ),




            ],



          ),



        ),



      ),



    );


  }


}