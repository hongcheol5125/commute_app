import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool choolCheckDone = false;
  GoogleMapController? mapController;

  // latitude - 위도  ,  longitude - 경도
  static final LatLng companyLatLng = LatLng(
    35.122339541881,
    126.86703266041,
  ); // 풍암고 위도, 경도 가져옴

  // 위치표시 변수
  static final CameraPosition initialPosition = CameraPosition(
    target: companyLatLng,
    zoom: 15, // 확대한 정도(Zoom Level)
  );

  static final double okDisatance = 100;

  static final Circle withinDistanceCircle = Circle(
    circleId: CircleId('withinDistanceCircle'),
    center: companyLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: okDisatance,
    strokeColor: Colors.blue, // 원 둘레 색깔
    strokeWidth: 1, // 원 둘레를 몇픽셀 두께로 칠할건지
  );

  static final Circle notWithinDistanceCircle = Circle(
    circleId: CircleId('notWithinDistanceCircle'),
    center: companyLatLng,
    fillColor: Colors.red.withOpacity(0.5),
    radius: okDisatance,
    strokeColor: Colors.red, // 원 둘레 색깔
    strokeWidth: 1, // 원 둘레를 몇픽셀 두께로 칠할건지
  );

  static final Circle checkDoneCircle = Circle(
    circleId: CircleId('checkDoneCircle'),
    center: companyLatLng,
    fillColor: Colors.green.withOpacity(0.5),
    radius: okDisatance,
    strokeColor: Colors.green, // 원 둘레 색깔
    strokeWidth: 1, // 원 둘레를 몇픽셀 두께로 칠할건지
  );

  static final Marker marker = Marker(
    markerId: MarkerId('marker'),
    position: companyLatLng,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        // FutureBuilder는 future를 return 해주는 함수만 받을 수 있다.
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // FutureBuilder는 AsyncSnapshot snapshot도 받는다.
          // print(snapshot.connectionState); --> snapshot 연결 상태를 프린트해줌(none[future함수 없을 때], waiting, active[streem에서만 사용], done 있음)
          //   print(snapshot.data); --> print(snapshot.data); 하면 checkPermission 함수를 프린트 할 수 있다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == '위치 권한이 허가되었습니다.') {
            return StreamBuilder<Position>(
              stream: Geolocator.getPositionStream(),
              builder: (context, snapshot) {
                bool isWithinRange = false;

                if (snapshot.hasData) {
                  final start =
                      snapshot.data!; // hasData이면 null일 수가 없으므로 ! 붙여주자
                  final end = companyLatLng;

                  final distance = Geolocator.distanceBetween(
                    start.latitude,
                    start.longitude,
                    end.latitude,
                    end.longitude,
                  );

                  if (distance < okDisatance) {
                    isWithinRange = true;
                  }
                }

                return Column(
                  children: [
                    _CustomGoogleMap(
                      initialPosition: initialPosition,
                      circle: choolCheckDone
                          ? checkDoneCircle
                          : isWithinRange
                              ? withinDistanceCircle
                              : notWithinDistanceCircle,
                      marker: marker,
                      onMapCreated: onMapCreated,
                    ),
                    _ChoolCheckButton(
                      isWithinRange: isWithinRange,
                      choolCheckDone: choolCheckDone,
                      onPressed: onChoolCheckPressed,
                    ),
                  ],
                );
              },
            );
          }

          return Center(
            child: Text(snapshot.data),
          );
        },
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  onChoolCheckPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // AlertDialog
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('출근하기'),
            ),
          ],
        );
      },
    );

    if (result) {
      setState(() {
        choolCheckDone = true;
      });
    }
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
      // deniedForever는 한번 권한 취소하면 설정에 들어가서 직접 요청해야한다
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    return '위치 권한이 허가되었습니다.';
  }

  AppBar renderAppBar() {
    return AppBar(
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            // 현재위치를 가져와야하므로 async 씀
            if (mapController == null) {
              return;
            }

            final location = await Geolocator.getCurrentPosition();

            mapController!.animateCamera(
              CameraUpdate.newLatLng(LatLng(
                location.latitude,
                location.longitude,
              )),
            );
          },
          icon: Icon(
            Icons.my_location,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  final Circle circle;
  final Marker marker;
  final MapCreatedCallback onMapCreated;

  const _CustomGoogleMap(
      {required this.initialPosition,
      required this.circle,
      required this.marker,
      required this.onMapCreated,
      super.key});

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
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: onMapCreated,
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  final bool isWithinRange;
  final VoidCallback onPressed;
  final bool choolCheckDone;
  const _ChoolCheckButton({
    required this.isWithinRange,
    required this.onPressed,
    required this.choolCheckDone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timelapse_outlined,
          size: 50.0,
          color: choolCheckDone
              ? Colors.green
              : isWithinRange
                  ? Colors.blue
                  : Colors.red,
        ),
        const SizedBox(
          height: 20.0,
        ),
        if (!choolCheckDone &&
            isWithinRange) // 함수가 아닌 위젯에서 if문을 쓸 땐, if(){}가 아닌 if()로 씀
          TextButton(
            onPressed: onPressed,
            child: Text('출근하기'),
          ),
      ],
    ));
  }
}

  // AppBar를 이렇게 쓸 수도 있음
// 굳이 class로 만들지 않고  appBar 메소드로 만들어서 쓰면 훨씬 더 간단해!!!!
// class _RenderAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final AppBar appBar;

//   const _RenderAppBar({required this.appBar, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         '오늘도 출근',
//         style: TextStyle(
//           color: Colors.blue,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         IconButton(
//           onPressed: () {},
//           icon: Icon(
//             Icons.my_location,
//             color: Colors.blue,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
// }
