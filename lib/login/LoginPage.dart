import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/registration/IdentityVerificationPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/login/LoginInfoFindPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isReady = true; //서버중복신호방지

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isCheckEmail = false;
  String loginID = "";
  String loginPassword = "";
  String? errMsg4Password;

  bool validPassword(String password) {
    if (!kReleaseMode) return true;

    loginPassword = password;
    if (password.length < 1 || password == null) {
      errMsg4Password = "비밀번호를 입력해주세요.";
      return false;
    } else {
      errMsg4Password = null;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SocketProvider provider = SocketProvider.to;
    provider.setLocalNotification(LocalNotification());
    provider.setChatGlobal(Get.put(ChatGlobal()));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: GestureDetector(
          onTap: () {
            unFocus(context);
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Scaffold(
                  appBar: SheepsAppBar(context, ''),
                  body: SingleChildScrollView(
                    child: Container(
                      color: Colors.white, //채우기용
                      child: Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 26 * sizeUnit),
                            SvgPicture.asset(
                              svgSheepsFullLogo,
                              color: sheepsColorGreen,
                              width: 80 * sizeUnit,
                              height: 80 * sizeUnit,
                            ),
                            SizedBox(height: 32 * sizeUnit),
                            Text(
                              '쉽스와 함께 창업을\n쉽고, 멋지게 시작.',
                              style: SheepsTextStyle.h5(),
                            ),
                            Row(children: [SizedBox(height: 48 * sizeUnit)]),
                            sheepsTextField(
                              context,
                              title: '로그인 이메일',
                              controller: _idController,
                              hintText: '이메일을 적어주세요.',
                              errorText: validEmailErrorText(_idController.text) == 'empty' ? null : validEmailErrorText(_idController.text),
                              onChanged: (val) {
                                validEmailErrorText(val) == null ? isCheckEmail = true : isCheckEmail = false;
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 16 * sizeUnit),
                            sheepsTextField(
                              context,
                              title: '비밀번호',
                              controller: _passwordController,
                              hintText: '비밀번호를 입력하세요.',
                              errorText: errMsg4Password,
                              obscureText: true,
                              onChanged: (val) {
                                validPassword(val);
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 40 * sizeUnit),
                            Container(
                              width: 320 * sizeUnit,
                              height: 54 * sizeUnit,
                              decoration: BoxDecoration(
                                color: sheepsColorGreen,
                                borderRadius: BorderRadius.circular(12 * sizeUnit),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (_isReady && _idController.text.isNotEmpty && validPassword(_passwordController.text)) {
                                    _isReady = false; //서버중복신호방지
                                    (() async {
                                      String loginURL = !kReleaseMode ? '/Personal/Select/DebugLogin' : '/Personal/Select/Login';

                                      var result = await ApiProvider().post(
                                          loginURL,
                                          jsonEncode({
                                            "id": _idController.text,
                                            "password": _passwordController.text,
                                          }));

                                      if (null != result) {
                                        if (result['result'] == null) {
                                          if (result['res'] == 2) {
                                            Function okFunc = () {
                                              globalLoginID = _idController.text;

                                              Get.back();

                                              Get.to(IdentityVerificationPage(identityStatus: IdentityStatus.SignUP));
                                            };

                                            Function cancelFunc = () {
                                              Get.back();
                                            };

                                            _isReady = true; //서버중복신호방지
                                            showSheepsDialog(
                                              context: context,
                                              title: '핸드폰 인증 필요',
                                              description: "해당 아이디는 핸드폰 인증이 필요합니다.\n인증 페이지로 가시겠어요?",
                                              okText: '갈게요',
                                              okFunc: okFunc,
                                              cancelText: '좀 더 생각해볼게요',
                                              cancelFunc: cancelFunc,
                                            );
                                            return;
                                          } else {
                                            Function okFunc = () {
                                              ApiProvider().post('/Personal/Logout', jsonEncode({"userID": result['userID'], "isSelf": 0}), isChat: true);

                                              Get.back();
                                            };

                                            showSheepsDialog(
                                              context: context,
                                              title: "로그아웃",
                                              description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
                                              okText: "로그아웃 할게요",
                                              okFunc: okFunc,
                                              cancelText: "좀 더 생각해볼게요",
                                            );
                                            _isReady = true; //서버중복신호방지
                                            return;
                                          }
                                        }

                                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setBool('autoLoginKey', true);
                                        prefs.setString('autoLoginId', _idController.text);
                                        prefs.setString('autoLoginPw', _passwordController.text);
                                        prefs.setString('socialLogin', 0.toString());

                                        globalLogin(context, provider, result);
                                      } else {
                                        showSheepsDialog(
                                          context: context,
                                          title: "로그인 실패",
                                          description: "가입하지 않은 아이디이거나\n잘못된 비밀번호입니다",
                                          isCancelButton: false,
                                        );
                                        _isReady = true; //서버중복신호방지
                                      }
                                    })();
                                  } else {
                                    setState(() {
                                      debugPrint("login fail");
                                    });
                                    _isReady = true;
                                  }
                                },
                                child: Text(
                                  "쉽스에 로그인",
                                  style: SheepsTextStyle.button1(),
                                ),
                              ),
                            ),
                            // SheepsBottomButton(
                            //   context: context,
                            //   function: () {
                            //     if (_isReady && isCheckEmail && validPassword(loginPassword)) {
                            //       _isReady = false; //서버중복신호방지
                            //       (() async {
                            //         String loginURL = !kReleaseMode ? '/Personal/Select/DebugLogin' : '/Personal/Select/Login';
                            //
                            //         var result = await ApiProvider().post(
                            //             loginURL,
                            //             jsonEncode({
                            //               "id": _idController.text,
                            //               "password": _passwordController.text,
                            //             }));
                            //
                            //         if (null != result) {
                            //           if (result['result'] == null) {
                            //             if (result['res'] == 2) {
                            //               Function okFunc = () {
                            //                 globalLoginID = _idController.text;
                            //
                            //                 Get.back();
                            //
                            //                 Get.to(IdentityVerificationPage(identityStatus: IdentityStatus.SignUP));
                            //               };
                            //
                            //               Function cancelFunc = () {
                            //                 Get.back();
                            //               };
                            //
                            //               _isReady = true; //서버중복신호방지
                            //               showSheepsDialog(
                            //                 context: context,
                            //                 title: '핸드폰 인증 필요',
                            //                 description: "해당 아이디는 핸드폰 인증이 필요합니다.\n인증 페이지로 가시겠어요?",
                            //                 okText: '갈게요',
                            //                 okFunc: okFunc,
                            //                 cancelText: '좀 더 생각해볼게요',
                            //                 cancelFunc: cancelFunc,
                            //               );
                            //               return;
                            //             } else {
                            //               Function okFunc = () {
                            //                 ApiProvider().post('/Personal/Logout', jsonEncode({"userID": result['userID'], "isSelf": 0}), isChat: true);
                            //
                            //                 Get.back();
                            //               };
                            //
                            //               showSheepsDialog(
                            //                 context: context,
                            //                 title: "로그아웃",
                            //                 description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
                            //                 okText: "로그아웃 할게요",
                            //                 okFunc: okFunc,
                            //                 cancelText: "좀 더 생각해볼게요",
                            //               );
                            //               _isReady = true; //서버중복신호방지
                            //               return;
                            //             }
                            //           }
                            //
                            //           final SharedPreferences prefs = await SharedPreferences.getInstance();
                            //           prefs.setBool('autoLoginKey', true);
                            //           prefs.setString('autoLoginId', _idController.text);
                            //           prefs.setString('autoLoginPw', _passwordController.text);
                            //           prefs.setString('socialLogin', 0.toString());
                            //
                            //           globalLogin(context, provider, result);
                            //         } else {
                            //           showSheepsDialog(
                            //             context: context,
                            //             title: "로그인 실패",
                            //             description: "가입하지 않은 아이디이거나\n잘못된 비밀번호입니다",
                            //             isCancelButton: false,
                            //           );
                            //           _isReady = true; //서버중복신호방지
                            //         }
                            //       })();
                            //     } else {
                            //       setState(() {
                            //         debugPrint("login fail");
                            //       });
                            //       _isReady = true;
                            //     }
                            //   },
                            //   text: '쉽스에 로그인',
                            // ),
                            SizedBox(height: 20 * sizeUnit),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => LoginInfoFindPage());
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "아이디, 비밀번호가 생각나지 않나요?",
                                          style: SheepsTextStyle.info1(),
                                        ),
                                        TextSpan(
                                          text: " 찾기",
                                          style: SheepsTextStyle.infoStrong(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
