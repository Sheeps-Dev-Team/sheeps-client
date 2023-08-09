import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/profileModify/models/PersonalProfileModifyController.dart';
import 'package:sheeps_app/userdata/User.dart';

import 'AuthFileUploadPage.dart';

class AddLicensePage extends StatefulWidget {
  @override
  _AddLicenseState createState() => _AddLicenseState();
}

class _AddLicenseState extends State<AddLicensePage> {
  PersonalProfileModifyController controller = Get.put(PersonalProfileModifyController());
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  String date = '';

  File? authFile;

  @override
  void dispose() {
    licenseController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  bool isOk() {
    bool _isOk = true;
    if (licenseController.text.isEmpty) _isOk = false;
    if (organizationController.text.isEmpty) _isOk = false;
    if (date.isEmpty) _isOk = false;
    if (authFile == null) _isOk = false;
    return _isOk;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () {
          unFocus(context);
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: null,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: SheepsAppBar(context, '자격증 추가'),
                  body: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('자격증', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: licenseController,
                                    hintText: 'ex) 정보처리기사',
                                    borderColor: sheepsColorBlue,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('발급기관', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  multiLineTextField(
                                    controller: organizationController,
                                    hintText: 'ex) 한국산업인력공단',
                                    borderColor: sheepsColorBlue,
                                    isOneLine: true,
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Text('취득일', style: SheepsTextStyle.h3()),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1960),
                                        lastDate: DateTime.now(),
                                        helpText: '날짜 선택',
                                        cancelText: '취소',
                                        confirmText: '확인',
                                        locale: const Locale('ko', 'KR'),
                                        initialDatePickerMode: DatePickerMode.year,
                                        errorFormatText: '형식이 맞지 않습니다.',
                                        errorInvalidText: '형식이 맞지 않습니다!',
                                        fieldLabelText: '날짜 입력',
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData(
                                              fontFamily: 'SpoqaHanSansNeo',
                                              colorScheme: ColorScheme.fromSwatch(
                                                primarySwatch: Colors.grey,
                                              ),
                                            ),
                                            child: child ?? const SizedBox.shrink(),
                                          );
                                        },
                                      ).then((value) {
                                        setState(() {
                                          if (value != null) {
                                            date = value.year.toString() + '.' + value.month.toString();
                                          }
                                        });
                                      });
                                    },
                                    child: pickDateContainer(text: date, color: sheepsColorBlue),
                                  ),
                                  SizedBox(height: 20 * sizeUnit),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: '증빙 자료',
                                        ),
                                        style: SheepsTextStyle.h3(),
                                      ),
                                      SizedBox(width: 8 * sizeUnit),
                                      Text('자격증 사본, 합격증명서 등', style: SheepsTextStyle.info2()),
                                    ],
                                  ),
                                  SizedBox(height: 12 * sizeUnit),
                                  GestureDetector(
                                    onTap: () {
                                      unFocus(context);
                                      Get.to(() => AuthFileUploadPage(appBarTitle: '자격증 증빙 자료', authFile: authFile))?.then((value) {
                                        if (value != null) {
                                          setState(() {
                                            authFile = value[0];
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 328 * sizeUnit,
                                      height: 32 * sizeUnit,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: authFile != null ? sheepsColorBlue : sheepsColorGrey, width: 1 * sizeUnit),
                                        borderRadius: BorderRadius.circular(16 * sizeUnit),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 12 * sizeUnit),
                                            child: Container(
                                              width: 284 * sizeUnit,
                                              child: Text(
                                                authFile != null ? authFile!.path.substring(authFile!.path.lastIndexOf('\/') + 1) : '증빙 자료는 1개의 업로드만 가능해요',
                                                style: SheepsTextStyle.hint4Profile().copyWith(color: authFile != null ? sheepsColorBlue : sheepsColorGrey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(right: 12 * sizeUnit),
                                            child: SvgPicture.asset(
                                              svgGreyNextIcon,
                                              width: 12 * sizeUnit,
                                              color: sheepsColorGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20 * sizeUnit),
                        child: SheepsBottomButton(
                          context: context,
                          function: () {
                            if (isOk()) {
                              String license = licenseController.text;
                              String organization = organizationController.text;

                              String contents = license + ' \/ ' + organization + '||' + date;

                              bool isSameData = false;
                              for(int i = 0; i < controller.licenseList.length; i++){
                                if(contents == controller.licenseList[i].contents){
                                  isSameData = true;
                                  break;
                                }
                              }
                              if(isSameData){
                                showAddFailDialog(title: '자격증', okButtonColor: sheepsColorBlue);
                              }else{
                                controller.licenseList.add(UserLicense(
                                  id: -1,
                                  contents: contents,
                                  imgUrl: authFile!.path, //우선 파일경로 저장. 이후 수정 완료시 처리. id -1으로 확인
                                  auth: 2,
                                ));
                                Get.back();
                              }
                            }
                          },
                          text: '자격증 추가',
                          color: sheepsColorBlue,
                          isOK: isOk(),
                        ),
                      ),
                    ],
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
