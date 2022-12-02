import 'package:uni_links/uni_links.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'main.dart';
import 'package:get/get.dart';

class DynamicLink {
  Future<bool> setup() async {
    print('setup_실행됨');
    bool isExistDynamicLink = await _getInitialDynamicLink();
    _addListener();

    return isExistDynamicLink;
  }

  Future<bool> _getInitialDynamicLink() async {
    final String? deepLink = await getInitialLink();
    print('_getInitialDynamicLink 실행됨');
    if (deepLink != null) {
      PendingDynamicLinkData? dynamicLinkData = await FirebaseDynamicLinks
          .instance
          .getDynamicLink(Uri.parse(deepLink));

      if (dynamicLinkData != null) {
        print('dynamic_link=$dynamicLinkData');
        Get.to(() => const SecondRoute());

        return true;
      }
    }

    return false;
  }

  void _addListener() {
    print('_addListener 실행됨');
    FirebaseDynamicLinks.instance.onLink.listen((
        PendingDynamicLinkData dynamicLinkData,) {
      Get.to(() => const SecondRoute());
    }).onError((error) {
      print('error=$error');
    });
  }

  // void _redirectScreen(PendingDynamicLinkData dynamicLinkData) {
  //   if (dynamicLinkData.link.queryParameters.containsKey('id')) {
  //     String link = dynamicLinkData.link.path
  //         .split('/')
  //         .last;
  //     String id = dynamicLinkData.link.queryParameters['id']!;
  //
  //     switch (link) {
  //       case exhibition:
  //         Get.offAll(
  //               () =>
  //               ExhibitionDetailScreen(
  //                 mainBottomTabIndex: MainBottomTabScreenType.exhibitionMap
  //                     .index,
  //               ),
  //           arguments: {
  //             "exhibitionId": id,
  //           },
  //         );
  //         break;
  //       case artist:
  //         Get.offAll(
  //               () => ArtistScreen(),
  //           arguments: {
  //             "artistId": id,
  //           },
  //         );
  //         break;
  //       case exhibitor:
  //         Get.offAll(
  //               () => ExhibitorScreen(),
  //           arguments: {
  //             "exhibitorId": id,
  //           },
  //         );
  //         break;
  //     }
  //   }
  // }
}