import 'dart:io';

import 'package:clone_tiktok/constant.dart';
import 'package:clone_tiktok/models/user.dart'
    as model; // 파이어베이스로부터 가져온 유저 정보는 model
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/*
  새 사용자를 등록하고 프로필 사진을 Firebase 저장소에 업로드
*/

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  /*
    싱글톤은 애플리케이션 전체에서 특정 클래스의 인스턴스가 하나만 있도록 하는 디자인 패턴입니다.
    매번 새 인스턴스를 생성할 필요 없이 애플리케이션의 모든 부분에서 쉽게 액세스할 수 있습니다. 
    이는 메모리 사용량을 줄이고 성능을 향상시키는 데 도움이 될 수 있습니다.

    find 메서드는 AuthController의 싱글톤 인스턴스를 검색하는 데 사용됩니다.  
    클래스는 AuthController 클래스의 메서드 및 속성에 액세스하는 데 사용할 수 있습니다. 
    new AuthController() 대신 Get.find()를 사용하면 AuthController 클래스의 인스턴스가 하나만 생성되고 
    사용되도록 할 수 있습니다. 

    요약하면, Get 패키지의 find 메서드를 사용하여 애플리케이션 전체에서 클래스의 인스턴스 하나만 생성되고 사용되도록 합니다.
  */
  /*
    이미지를 나타내는 File 개체를 가져와 Firebase 저장소에 업로드하는 비동기 메서드입니다. 
    먼저 이미지를 업로드해야 하는 Firebase 저장소의 위치를 ​​나타내는 Reference 객체를 생성합니다. 
    그런 다음 putFile() 메서드를 호출하여 파일을 업로드하고 await를 사용하여 업로드가 완료될 때까지 기다립니다. 
    업로드가 완료되면 TaskSnapshot의 getDownloadURL() 메서드를 사용하여 업로드된 파일의 다운로드 URL을 검색합니다. 
    마지막으로 다운로드 URL을 Future로 반환합니다.
  */

  late Rx<File?> _pickedImage = Rx<File?>(null);
  /*
    Rx는 반응 변수를 생성하는 데 사용되는 Get 패키지의 클래스입니다. 
    late 키워드는 _pickedImage 변수가 미래의 어느 시점에 초기화될 것임을 나타내는 데 사용됩니다.

    아래 메서드는 사용자 장치의 갤러리에서 이미지를 선택하는 데 사용됩니다. 
    image_picker 패키지의 ImagePicker() 클래스를 사용하여 이미지를 선택합니다. 
    await 키워드는 사용자가 갤러리에서 이미지를 선택할 때까지 기다리는 데 사용됩니다.
    Get.snackbar는 화면 하단에 알림 메시지를 표시하는 데 사용됩니다.

    성공 메시지를 표시한 후 를 사용하여 Rx 객체를 생성합니다. 
    Rx() 생성자는 변수 값의 변경 사항을 수신하는 데 사용할 수 있는 반응 변수를 만드는 데 사용됩니다. 
    path 속성을 ​​사용하여 pickedImage 변수에서 가져온 선택한 이미지의 파일 경로로 _pickedImage 변수를 초기화합니다.

    Rx 개체의 value 속성을 ​​사용하여 _pickedImage 변수의 현재 값을 가져올 수도 있습니다.

    요약하면 사용자 기기의 갤러리에서 이미지를 선택하고 선택한 이미지의 변경사항을 수신하는 데 사용할 수 있는 
    반응 변수(Rx)를 만드는 데 사용됩니다. 
    Get.snackbar() 메서드는 갤러리에서 이미지가 성공적으로 선택되었을 때 성공 메시지를 표시하는 데 사용됩니다.
  */

  File? get profilePhoto => _pickedImage.value;

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar('Profile Picture',
          'You have successfully selected your profile picture!');
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
    // _pickedImage = File(pickedImage!.path);
  }

  // upload to firebase storage
  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  /*
    registerUser() 메서드가 정의됩니다. 사용자 이름, 이메일, 비밀번호 및 선택적 이미지 파일을 가져오는 비동기 방식입니다. 
    먼저 모든 필수 필드가 비어 있지 않고 이미지 파일이 제공되었는지 확인합니다. 
    그런 다음 firebaseAuth 개체에서 createUserWithEmailAndPassword() 메서드를 호출하여 Firebase 인증에서 
    새 사용자를 만듭니다. 
    사용자가 생성되면 _uploadToStorage() 메서드를 호출하여 이미지 파일을 Firebase 저장소에 업로드하고 
    다운로드 URL을 가져옵니다. 
    마지막으로 사용자 정보로 새로운 model.User 객체를 생성하고 Get.snackbar() 메서드를 호출하여 오류가 발생할 경우 
    오류 메시지를 표시합니다.
  */

  // registering the user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );
        /*
          Cloud Firestore의 users 컬렉션에서 새 문서를 생성하는 역할을 합니다.

          The cred.user! .uid 속성은 Firebase 인증에서 방금 생성된 사용자의 고유 식별자(UID)를 검색하는 데 사용됩니다. 
          이 UID는 users 컬렉션의 새 문서에 대한 문서 ID로 사용됩니다.

          set() 메서드는  새 문서의 데이터를 설정하기 위해 firestore.collection('users').doc(cred.user!.uid)에서 
          반환된 DocumentReference 개체입니다. 
          데이터는 Map 개체로 제공되며 user 개체에서 toJson() 메서드를 호출하여 가져옵니다. 

          결국 이 코드는 이름, 이메일, 프로필 사진, UID와 같은 사용자 정보가 포함된 Cloud Firestore의 users 컬렉션에 
          새 문서를 생성합니다. 
          user 개체는 먼저 toJson() 메서드를 사용하여 Map로 변환된 다음 에 전달됩니다. 
          >set() 메서드를 사용하여 새 문서의 데이터를 설정합니다.

          이 코드는 사용자 정보를 Cloud Firestore에 저장하여 검색하고 표시하는 데 사용할 수 있기 때문에 중요합니다. 
          응용 프로그램 전체에서 사용자 정보. 사용자의 UID를 문서 ID로 사용하여 users 컬렉션에 문서를 생성하면 
          사용자의 UID로 users 컬렉션을 쿼리하여 사용자 정보를 쉽게 검색할 수 있습니다.
         */
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fileds',
        );
      }
    } catch (e) {
      Get.snackbar('Error Creating Account', e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        print('log success');
      } else {
        Get.snackbar(
          'Error',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar('Error Login Account', e.toString());
    }
  }
}
