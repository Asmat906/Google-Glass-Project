import 'package:google_glass_app/utils.dart';

class TaskMaterial {
  String gtin = "";
  List<String> imageUrl = [];
  String manufacturer = "";
  String description = "";

  static TaskMaterial createFromJson(dynamic hit) {
    TaskMaterial tm = TaskMaterial();
    tm.gtin = hit['gtin'];
    tm.manufacturer = hit['manufacturer'];
    tm.description = hit['description'];

    if (hit['imageUrl'] != null) {
      tm.imageUrl.add(hit['imageUrl']);
    }
    if (hit['imageUrl2'] != null) {
      tm.imageUrl.add(hit['imageUrl2']);
    }
    downloadGtinDocuments(tm.gtin);
    return tm;
  }

  static List<String> acceptedTypes = ["VI", "VM", "DB", "IS", "MA", "MZ"];

  static downloadGtinDocuments(String gtin) async {
    String name = "TOTO WASHLET RX EWATER+ weiß";
    String gtin = "4050663095444";

    List<String> fileList =  ["TODBTCF894CG.PDF","TOISTCF894CG.PDF","TOMATCF894CG.PDF","TOVI_CleanSynergy.MP4","TOVI_WASHLET_Beheizter_Sitz.MP4","TOVI_WASHLET_DEODORIZER.MP4","TOVI_WASHLET_ewater_plus_GER.MP4","TOVI_WASHLET_RX.MP4","TOVM_Installationsan_RWSW_RXSX.MP4","TOVM_Schnellstart_SX_RX_EWATER.MP4"];

    for (int i = 0; i < fileList.length; i++) {
        await Utils.downloadMovieFromOpenDataPool(
            gtin, name, fileList[i]);
    }
  }
}
