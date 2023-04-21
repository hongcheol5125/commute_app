import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // latitude - 위도  ,  longitude - 경도
  static final LatLng companyLatLng = LatLng(
    37.5233273,
    126.921252,
  ); // 코팩 회사가 여의도여서 여의도 위,경도 가져옴

  // 위치표시 변수
  static final CameraPosition initialPosition = CameraPosition(
    target: companyLatLng,
    zoom: 15, // 확대한 정도(Zoom Level)
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _RenderAppBar(
        appBar: AppBar(),
      ),
      body: Column(
        children: [
          _CustomGoogleMap(initialPosition: initialPosition),
          _ChoolCheckButton(),
        ],
      ),
    );
  }

  // 위치권한 확인-Geolocator(모든 위치권한 받는 것들은 async로 작업해야한다! 왜냐면, 유저가 권한을 눌러주면 그때서야 권한가능하기때문에)
  Future<String> checkPermission() async {
    // Future<String>쓴 이유는 나중에 String값 return 받을거니까 써준거~
    final isLocationEnabled = await Geolocator
        .isLocationServiceEnabled(); // isLocationServiceEnabled은 핸드폰 자체에서 위치서비스 이용할 수 있는지 정하는 버튼이 true인지 false인지 정하는 코드이다.

    if (!isLocationEnabled) // !isLocationEnabled 은 "isLocationEnabled가 false이다" 라는 뜻
    {
      return '위치 서비스를 활성화 해주세요';
    }
    // checkPermission()은 현재 앱이 갖고있는 위치서비스권한이 어떻게 되는지를 LocationPermission형태로 가져옴
    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    return '위치 권한이 허가되었습니다.';
  }

  // AppBar를 이렇게 쓸 수도 있음
  // AppBar renderAppBar() {
  //   return AppBar(
  //     title: Text(
  //       '오늘도 출근',
  //       style: TextStyle(
  //         color: Colors.blue,
  //         fontWeight: FontWeight.w700,
  //       ),
  //     ),
  //     backgroundColor: Colors.white,
  //   );
  // }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  const _CustomGoogleMap({required this.initialPosition, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal, // (기본지도)
        // mapType: MapType.hybrid, (위성지도)
        // mapType: MapType.satellite, (위성지도)
        // mapType: MapType.terrain, (높낮이 나타나는 지도)
        initialCameraPosition: initialPosition, // 처음 카메라 위치
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  const _ChoolCheckButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text('출근'),
    );
  }
}

class _RenderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const _RenderAppBar({required this.appBar, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
