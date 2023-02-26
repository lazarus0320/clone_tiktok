import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String profilePhoto;
  String email;
  String uid;

  User({
    required this.name,
    required this.profilePhoto,
    required this.email,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "profilePhoto": profilePhoto,
        "email": email,
        "uid": uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    /**
     * User 클래스의 fromSnap 메서드는 cloud_firestore에서 DocumentSnapshot 개체를 가져오는 정적 팩터리 메서드입니다. 
     * 
     * code> 패키지를 만들고 스냅샷에서 추출된 값과 함께 User 클래스의 새 인스턴스를 반환합니다.
     * 이 메서드는 Firestore 컬렉션의 단일 문서를 나타내는 DocumentSnapshot 객체를 가져옵니다.
     * 
     * snap.data() 메서드는 스냅샷에서 데이터를 가져오기 위해 호출됩니다. 이 데이터는 Map 개체로 반환됩니다.
     * snapshot 변수는 snap.data()에 의해 반환된 Map 객체.
     * The User  개체는 snapshot 맵에서 추출한 값을 사용하여 생성됩니다. name, profilePhoto, 
     * email 및 uid 속성의 값은 snapshot< /code> 해당 키를 사용하여 매핑합니다.
     * User 개체가 반환됩니다.
     * 이 fromSnap 메서드는 Firestore 쿼리에서 반환된 DocumentSnapshot 객체에서 User 객체를 생성하는 유용한 방법입니다. 
     * 이를 통해 스냅샷 데이터를 애플리케이션에서 사용할 수 있는 사용 가능한 User 개체로 쉽게 변환할 수 있습니다. 
     * 이 메서드는 또한 정적으로 선언되므로 이 메서드를 사용하기 위해 User 클래스의 인스턴스를 생성할 필요가 없습니다.
     */
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      name: snapshot['name'],
      profilePhoto: snapshot['profilePhoto'],
      email: snapshot['email'],
      uid: snapshot['uid'],
    );
  }
}
