import 'dart:async';

import 'package:attendance_system/services/role_management/role_management_model.dart';
import 'package:attendance_system/services/role_management/role_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/user_cancel_checkbox.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/head_bar/header.dart';
import '../../../shared/widgets/helper/color_picker_popup/color_picker.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/popup/floating_popup.dart';
import '../../../shared/widgets/utils/popup/option_popup.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/services/service_updater.dart';

Future<Response> getMemberAll() async {
  await Future.delayed(const Duration(milliseconds: 500));

  final mockData = {
    "members": [
      {
        "id": "EMP001",
        "thName": "พนักงาน 1",
        "enName": "Employee 1",
        "avatarUrl": "https://i.pravatar.cc/150?img=1"
      },
      {
        "id": "EMP002",
        "thName": "พนักงาน 2",
        "enName": "Employee 2",
        "avatarUrl": "https://i.pravatar.cc/150?img=2"
      },
      {
        "id": "EMP003",
        "thName": "พนักงาน 3",
        "enName": "Employee 3",
        "avatarUrl": "https://i.pravatar.cc/150?img=3"
      },
      {
        "id": "EMP004",
        "thName": "พนักงาน 4",
        "enName": "Employee 4",
        "avatarUrl": "https://i.pravatar.cc/150?img=4"
      },
      {
        "id": "EMP005",
        "thName": "พนักงาน 5",
        "enName": "Employee 5",
        "avatarUrl": "https://i.pravatar.cc/150?img=5"
      },
      {
        "id": "EMP006",
        "thName": "พนักงาน 6",
        "enName": "Employee 6",
        "avatarUrl": "https://i.pravatar.cc/150?img=6"
      },
      {
        "id": "EMP007",
        "thName": "พนักงาน 7",
        "enName": "Employee 7",
        "avatarUrl": "https://i.pravatar.cc/150?img=7"
      },
      {
        "id": "EMP008",
        "thName": "พนักงาน 8",
        "enName": "Employee 8",
        "avatarUrl": "https://i.pravatar.cc/150?img=8"
      },
      {
        "id": "EMP009",
        "thName": "พนักงาน 9",
        "enName": "Employee 9",
        "avatarUrl": "https://i.pravatar.cc/150?img=9"
      },
      {
        "id": "EMP010",
        "thName": "พนักงาน 10",
        "enName": "Employee 10",
        "avatarUrl": "https://i.pravatar.cc/150?img=10"
      },
      {
        "id": "EMP011",
        "thName": "พนักงาน 11",
        "enName": "Employee 11",
        "avatarUrl": "https://i.pravatar.cc/150?img=11"
      },
      {
        "id": "EMP012",
        "thName": "พนักงาน 12",
        "enName": "Employee 12",
        "avatarUrl": "https://i.pravatar.cc/150?img=12"
      },
      {
        "id": "EMP013",
        "thName": "พนักงาน 13",
        "enName": "Employee 13",
        "avatarUrl": "https://i.pravatar.cc/150?img=13"
      },
      {
        "id": "EMP014",
        "thName": "พนักงาน 14",
        "enName": "Employee 14",
        "avatarUrl": "https://i.pravatar.cc/150?img=14"
      },
      {
        "id": "EMP015",
        "thName": "พนักงาน 15",
        "enName": "Employee 15",
        "avatarUrl": "https://i.pravatar.cc/150?img=15"
      },
      {
        "id": "EMP016",
        "thName": "พนักงาน 16",
        "enName": "Employee 16",
        "avatarUrl": "https://i.pravatar.cc/150?img=16"
      },
      {
        "id": "EMP017",
        "thName": "พนักงาน 17",
        "enName": "Employee 17",
        "avatarUrl": "https://i.pravatar.cc/150?img=17"
      },
      {
        "id": "EMP018",
        "thName": "พนักงาน 18",
        "enName": "Employee 18",
        "avatarUrl": "https://i.pravatar.cc/150?img=18"
      },
      {
        "id": "EMP019",
        "thName": "พนักงาน 19",
        "enName": "Employee 19",
        "avatarUrl": "https://i.pravatar.cc/150?img=19"
      },
      {
        "id": "EMP020",
        "thName": "พนักงาน 20",
        "enName": "Employee 20",
        "avatarUrl": "https://i.pravatar.cc/150?img=20"
      },
      {
        "id": "EMP021",
        "thName": "พนักงาน 21",
        "enName": "Employee 21",
        "avatarUrl": "https://i.pravatar.cc/150?img=21"
      },
      {
        "id": "EMP022",
        "thName": "พนักงาน 22",
        "enName": "Employee 22",
        "avatarUrl": "https://i.pravatar.cc/150?img=22"
      },
      {
        "id": "EMP023",
        "thName": "พนักงาน 23",
        "enName": "Employee 23",
        "avatarUrl": "https://i.pravatar.cc/150?img=23"
      },
      {
        "id": "EMP024",
        "thName": "พนักงาน 24",
        "enName": "Employee 24",
        "avatarUrl": "https://i.pravatar.cc/150?img=24"
      },
      {
        "id": "EMP025",
        "thName": "พนักงาน 25",
        "enName": "Employee 25",
        "avatarUrl": "https://i.pravatar.cc/150?img=25"
      },
      {
        "id": "EMP026",
        "thName": "พนักงาน 26",
        "enName": "Employee 26",
        "avatarUrl": "https://i.pravatar.cc/150?img=26"
      },
      {
        "id": "EMP027",
        "thName": "พนักงาน 27",
        "enName": "Employee 27",
        "avatarUrl": "https://i.pravatar.cc/150?img=27"
      },
      {
        "id": "EMP028",
        "thName": "พนักงาน 28",
        "enName": "Employee 28",
        "avatarUrl": "https://i.pravatar.cc/150?img=28"
      },
      {
        "id": "EMP029",
        "thName": "พนักงาน 29",
        "enName": "Employee 29",
        "avatarUrl": "https://i.pravatar.cc/150?img=29"
      },
      {
        "id": "EMP030",
        "thName": "พนักงาน 30",
        "enName": "Employee 30",
        "avatarUrl": "https://i.pravatar.cc/150?img=30"
      },
      {
        "id": "EMP031",
        "thName": "พนักงาน 31",
        "enName": "Employee 31",
        "avatarUrl": "https://i.pravatar.cc/150?img=31"
      },
      {
        "id": "EMP032",
        "thName": "พนักงาน 32",
        "enName": "Employee 32",
        "avatarUrl": "https://i.pravatar.cc/150?img=32"
      },
      {
        "id": "EMP033",
        "thName": "พนักงาน 33",
        "enName": "Employee 33",
        "avatarUrl": "https://i.pravatar.cc/150?img=33"
      },
      {
        "id": "EMP034",
        "thName": "พนักงาน 34",
        "enName": "Employee 34",
        "avatarUrl": "https://i.pravatar.cc/150?img=34"
      },
      {
        "id": "EMP035",
        "thName": "พนักงาน 35",
        "enName": "Employee 35",
        "avatarUrl": "https://i.pravatar.cc/150?img=35"
      },
      {
        "id": "EMP036",
        "thName": "พนักงาน 36",
        "enName": "Employee 36",
        "avatarUrl": "https://i.pravatar.cc/150?img=36"
      },
      {
        "id": "EMP037",
        "thName": "พนักงาน 37",
        "enName": "Employee 37",
        "avatarUrl": "https://i.pravatar.cc/150?img=37"
      },
      {
        "id": "EMP038",
        "thName": "พนักงาน 38",
        "enName": "Employee 38",
        "avatarUrl": "https://i.pravatar.cc/150?img=38"
      },
      {
        "id": "EMP039",
        "thName": "พนักงาน 39",
        "enName": "Employee 39",
        "avatarUrl": "https://i.pravatar.cc/150?img=39"
      },
      {
        "id": "EMP040",
        "thName": "พนักงาน 40",
        "enName": "Employee 40",
        "avatarUrl": "https://i.pravatar.cc/150?img=40"
      },
      {
        "id": "EMP041",
        "thName": "พนักงาน 41",
        "enName": "Employee 41",
        "avatarUrl": "https://i.pravatar.cc/150?img=41"
      },
      {
        "id": "EMP042",
        "thName": "พนักงาน 42",
        "enName": "Employee 42",
        "avatarUrl": "https://i.pravatar.cc/150?img=42"
      },
      {
        "id": "EMP043",
        "thName": "พนักงาน 43",
        "enName": "Employee 43",
        "avatarUrl": "https://i.pravatar.cc/150?img=43"
      },
      {
        "id": "EMP044",
        "thName": "พนักงาน 44",
        "enName": "Employee 44",
        "avatarUrl": "https://i.pravatar.cc/150?img=44"
      },
      {
        "id": "EMP045",
        "thName": "พนักงาน 45",
        "enName": "Employee 45",
        "avatarUrl": "https://i.pravatar.cc/150?img=45"
      },
      {
        "id": "EMP046",
        "thName": "พนักงาน 46",
        "enName": "Employee 46",
        "avatarUrl": "https://i.pravatar.cc/150?img=46"
      },
      {
        "id": "EMP047",
        "thName": "พนักงาน 47",
        "enName": "Employee 47",
        "avatarUrl": "https://i.pravatar.cc/150?img=47"
      },
      {
        "id": "EMP048",
        "thName": "พนักงาน 48",
        "enName": "Employee 48",
        "avatarUrl": "https://i.pravatar.cc/150?img=48"
      },
      {
        "id": "EMP049",
        "thName": "พนักงาน 49",
        "enName": "Employee 49",
        "avatarUrl": "https://i.pravatar.cc/150?img=49"
      },
      {
        "id": "EMP050",
        "thName": "พนักงาน 50",
        "enName": "Employee 50",
        "avatarUrl": "https://i.pravatar.cc/150?img=50"
      },
      {
        "id": "EMP051",
        "thName": "พนักงาน 51",
        "enName": "Employee 51",
        "avatarUrl": "https://i.pravatar.cc/150?img=51"
      },
      {
        "id": "EMP052",
        "thName": "พนักงาน 52",
        "enName": "Employee 52",
        "avatarUrl": "https://i.pravatar.cc/150?img=52"
      },
      {
        "id": "EMP053",
        "thName": "พนักงาน 53",
        "enName": "Employee 53",
        "avatarUrl": "https://i.pravatar.cc/150?img=53"
      },
      {
        "id": "EMP054",
        "thName": "พนักงาน 54",
        "enName": "Employee 54",
        "avatarUrl": "https://i.pravatar.cc/150?img=54"
      },
      {
        "id": "EMP055",
        "thName": "พนักงาน 55",
        "enName": "Employee 55",
        "avatarUrl": "https://i.pravatar.cc/150?img=55"
      },
      {
        "id": "EMP056",
        "thName": "พนักงาน 56",
        "enName": "Employee 56",
        "avatarUrl": "https://i.pravatar.cc/150?img=56"
      },
      {
        "id": "EMP057",
        "thName": "พนักงาน 57",
        "enName": "Employee 57",
        "avatarUrl": "https://i.pravatar.cc/150?img=57"
      },
      {
        "id": "EMP058",
        "thName": "พนักงาน 58",
        "enName": "Employee 58",
        "avatarUrl": "https://i.pravatar.cc/150?img=58"
      },
      {
        "id": "EMP059",
        "thName": "พนักงาน 59",
        "enName": "Employee 59",
        "avatarUrl": "https://i.pravatar.cc/150?img=59"
      },
      {
        "id": "EMP060",
        "thName": "พนักงาน 60",
        "enName": "Employee 60",
        "avatarUrl": "https://i.pravatar.cc/150?img=60"
      },
      {
        "id": "EMP061",
        "thName": "พนักงาน 61",
        "enName": "Employee 61",
        "avatarUrl": "https://i.pravatar.cc/150?img=61"
      },
      {
        "id": "EMP062",
        "thName": "พนักงาน 62",
        "enName": "Employee 62",
        "avatarUrl": "https://i.pravatar.cc/150?img=62"
      },
      {
        "id": "EMP063",
        "thName": "พนักงาน 63",
        "enName": "Employee 63",
        "avatarUrl": "https://i.pravatar.cc/150?img=63"
      },
      {
        "id": "EMP064",
        "thName": "พนักงาน 64",
        "enName": "Employee 64",
        "avatarUrl": "https://i.pravatar.cc/150?img=64"
      },
      {
        "id": "EMP065",
        "thName": "พนักงาน 65",
        "enName": "Employee 65",
        "avatarUrl": "https://i.pravatar.cc/150?img=65"
      },
      {
        "id": "EMP066",
        "thName": "พนักงาน 66",
        "enName": "Employee 66",
        "avatarUrl": "https://i.pravatar.cc/150?img=66"
      },
      {
        "id": "EMP067",
        "thName": "พนักงาน 67",
        "enName": "Employee 67",
        "avatarUrl": "https://i.pravatar.cc/150?img=67"
      },
      {
        "id": "EMP068",
        "thName": "พนักงาน 68",
        "enName": "Employee 68",
        "avatarUrl": "https://i.pravatar.cc/150?img=68"
      },
      {
        "id": "EMP069",
        "thName": "พนักงาน 69",
        "enName": "Employee 69",
        "avatarUrl": "https://i.pravatar.cc/150?img=69"
      },
      {
        "id": "EMP070",
        "thName": "พนักงาน 70",
        "enName": "Employee 70",
        "avatarUrl": "https://i.pravatar.cc/150?img=70"
      },
      {
        "id": "EMP071",
        "thName": "พนักงาน 71",
        "enName": "Employee 71",
        "avatarUrl": "https://i.pravatar.cc/150?img=71"
      },
      {
        "id": "EMP072",
        "thName": "พนักงาน 72",
        "enName": "Employee 72",
        "avatarUrl": "https://i.pravatar.cc/150?img=72"
      },
      {
        "id": "EMP073",
        "thName": "พนักงาน 73",
        "enName": "Employee 73",
        "avatarUrl": "https://i.pravatar.cc/150?img=73"
      },
      {
        "id": "EMP074",
        "thName": "พนักงาน 74",
        "enName": "Employee 74",
        "avatarUrl": "https://i.pravatar.cc/150?img=74"
      },
      {
        "id": "EMP075",
        "thName": "พนักงาน 75",
        "enName": "Employee 75",
        "avatarUrl": "https://i.pravatar.cc/150?img=75"
      },
      {
        "id": "EMP076",
        "thName": "พนักงาน 76",
        "enName": "Employee 76",
        "avatarUrl": "https://i.pravatar.cc/150?img=76"
      },
      {
        "id": "EMP077",
        "thName": "พนักงาน 77",
        "enName": "Employee 77",
        "avatarUrl": "https://i.pravatar.cc/150?img=77"
      },
      {
        "id": "EMP078",
        "thName": "พนักงาน 78",
        "enName": "Employee 78",
        "avatarUrl": "https://i.pravatar.cc/150?img=78"
      },
      {
        "id": "EMP079",
        "thName": "พนักงาน 79",
        "enName": "Employee 79",
        "avatarUrl": "https://i.pravatar.cc/150?img=79"
      },
      {
        "id": "EMP080",
        "thName": "พนักงาน 80",
        "enName": "Employee 80",
        "avatarUrl": "https://i.pravatar.cc/150?img=80"
      },
      {
        "id": "EMP081",
        "thName": "พนักงาน 81",
        "enName": "Employee 81",
        "avatarUrl": "https://i.pravatar.cc/150?img=81"
      },
      {
        "id": "EMP082",
        "thName": "พนักงาน 82",
        "enName": "Employee 82",
        "avatarUrl": "https://i.pravatar.cc/150?img=82"
      },
      {
        "id": "EMP083",
        "thName": "พนักงาน 83",
        "enName": "Employee 83",
        "avatarUrl": "https://i.pravatar.cc/150?img=83"
      },
      {
        "id": "EMP084",
        "thName": "พนักงาน 84",
        "enName": "Employee 84",
        "avatarUrl": "https://i.pravatar.cc/150?img=84"
      },
      {
        "id": "EMP085",
        "thName": "พนักงาน 85",
        "enName": "Employee 85",
        "avatarUrl": "https://i.pravatar.cc/150?img=85"
      },
      {
        "id": "EMP086",
        "thName": "พนักงาน 86",
        "enName": "Employee 86",
        "avatarUrl": "https://i.pravatar.cc/150?img=86"
      },
      {
        "id": "EMP087",
        "thName": "พนักงาน 87",
        "enName": "Employee 87",
        "avatarUrl": "https://i.pravatar.cc/150?img=87"
      },
      {
        "id": "EMP088",
        "thName": "พนักงาน 88",
        "enName": "Employee 88",
        "avatarUrl": "https://i.pravatar.cc/150?img=88"
      },
      {
        "id": "EMP089",
        "thName": "พนักงาน 89",
        "enName": "Employee 89",
        "avatarUrl": "https://i.pravatar.cc/150?img=89"
      },
      {
        "id": "EMP090",
        "thName": "พนักงาน 90",
        "enName": "Employee 90",
        "avatarUrl": "https://i.pravatar.cc/150?img=90"
      },
      {
        "id": "EMP091",
        "thName": "พนักงาน 91",
        "enName": "Employee 91",
        "avatarUrl": "https://i.pravatar.cc/150?img=91"
      },
      {
        "id": "EMP092",
        "thName": "พนักงาน 92",
        "enName": "Employee 92",
        "avatarUrl": "https://i.pravatar.cc/150?img=92"
      },
      {
        "id": "EMP093",
        "thName": "พนักงาน 93",
        "enName": "Employee 93",
        "avatarUrl": "https://i.pravatar.cc/150?img=93"
      },
      {
        "id": "EMP094",
        "thName": "พนักงาน 94",
        "enName": "Employee 94",
        "avatarUrl": "https://i.pravatar.cc/150?img=94"
      },
      {
        "id": "EMP095",
        "thName": "พนักงาน 95",
        "enName": "Employee 95",
        "avatarUrl": "https://i.pravatar.cc/150?img=95"
      },
      {
        "id": "EMP096",
        "thName": "พนักงาน 96",
        "enName": "Employee 96",
        "avatarUrl": "https://i.pravatar.cc/150?img=96"
      },
      {
        "id": "EMP097",
        "thName": "พนักงาน 97",
        "enName": "Employee 97",
        "avatarUrl": "https://i.pravatar.cc/150?img=97"
      },
      {
        "id": "EMP098",
        "thName": "พนักงาน 98",
        "enName": "Employee 98",
        "avatarUrl": "https://i.pravatar.cc/150?img=98"
      },
      {
        "id": "EMP099",
        "thName": "พนักงาน 99",
        "enName": "Employee 99",
        "avatarUrl": "https://i.pravatar.cc/150?img=99"
      },
      {
        "id": "EMP100",
        "thName": "พนักงาน 100",
        "enName": "Employee 100",
        "avatarUrl": "https://i.pravatar.cc/150?img=100"
      },
      {
        "id": "EMP101",
        "thName": "พนักงาน 101",
        "enName": "Employee 101",
        "avatarUrl": "https://i.pravatar.cc/150?img=1"
      },
      {
        "id": "EMP102",
        "thName": "พนักงาน 102",
        "enName": "Employee 102",
        "avatarUrl": "https://i.pravatar.cc/150?img=2"
      },
      {
        "id": "EMP103",
        "thName": "พนักงาน 103",
        "enName": "Employee 103",
        "avatarUrl": "https://i.pravatar.cc/150?img=3"
      },
      {
        "id": "EMP104",
        "thName": "พนักงาน 104",
        "enName": "Employee 104",
        "avatarUrl": "https://i.pravatar.cc/150?img=4"
      },
      {
        "id": "EMP105",
        "thName": "พนักงาน 105",
        "enName": "Employee 105",
        "avatarUrl": "https://i.pravatar.cc/150?img=5"
      },
      {
        "id": "EMP106",
        "thName": "พนักงาน 106",
        "enName": "Employee 106",
        "avatarUrl": "https://i.pravatar.cc/150?img=6"
      },
      {
        "id": "EMP107",
        "thName": "พนักงาน 107",
        "enName": "Employee 107",
        "avatarUrl": "https://i.pravatar.cc/150?img=7"
      },
      {
        "id": "EMP108",
        "thName": "พนักงาน 108",
        "enName": "Employee 108",
        "avatarUrl": "https://i.pravatar.cc/150?img=8"
      },
      {
        "id": "EMP109",
        "thName": "พนักงาน 109",
        "enName": "Employee 109",
        "avatarUrl": "https://i.pravatar.cc/150?img=9"
      },
      {
        "id": "EMP110",
        "thName": "พนักงาน 110",
        "enName": "Employee 110",
        "avatarUrl": "https://i.pravatar.cc/150?img=10"
      },
      {
        "id": "EMP111",
        "thName": "พนักงาน 111",
        "enName": "Employee 111",
        "avatarUrl": "https://i.pravatar.cc/150?img=11"
      },
      {
        "id": "EMP112",
        "thName": "พนักงาน 112",
        "enName": "Employee 112",
        "avatarUrl": "https://i.pravatar.cc/150?img=12"
      },
      {
        "id": "EMP113",
        "thName": "พนักงาน 113",
        "enName": "Employee 113",
        "avatarUrl": "https://i.pravatar.cc/150?img=13"
      },
      {
        "id": "EMP114",
        "thName": "พนักงาน 114",
        "enName": "Employee 114",
        "avatarUrl": "https://i.pravatar.cc/150?img=14"
      },
      {
        "id": "EMP115",
        "thName": "พนักงาน 115",
        "enName": "Employee 115",
        "avatarUrl": "https://i.pravatar.cc/150?img=15"
      },
      {
        "id": "EMP116",
        "thName": "พนักงาน 116",
        "enName": "Employee 116",
        "avatarUrl": "https://i.pravatar.cc/150?img=16"
      },
      {
        "id": "EMP117",
        "thName": "พนักงาน 117",
        "enName": "Employee 117",
        "avatarUrl": "https://i.pravatar.cc/150?img=17"
      },
      {
        "id": "EMP118",
        "thName": "พนักงาน 118",
        "enName": "Employee 118",
        "avatarUrl": "https://i.pravatar.cc/150?img=18"
      },
      {
        "id": "EMP119",
        "thName": "พนักงาน 119",
        "enName": "Employee 119",
        "avatarUrl": "https://i.pravatar.cc/150?img=19"
      },
      {
        "id": "EMP120",
        "thName": "พนักงาน 120",
        "enName": "Employee 120",
        "avatarUrl": "https://i.pravatar.cc/150?img=20"
      },
      {
        "id": "EMP121",
        "thName": "พนักงาน 121",
        "enName": "Employee 121",
        "avatarUrl": "https://i.pravatar.cc/150?img=21"
      },
      {
        "id": "EMP122",
        "thName": "พนักงาน 122",
        "enName": "Employee 122",
        "avatarUrl": "https://i.pravatar.cc/150?img=22"
      },
      {
        "id": "EMP123",
        "thName": "พนักงาน 123",
        "enName": "Employee 123",
        "avatarUrl": "https://i.pravatar.cc/150?img=23"
      },
      {
        "id": "EMP124",
        "thName": "พนักงาน 124",
        "enName": "Employee 124",
        "avatarUrl": "https://i.pravatar.cc/150?img=24"
      },
      {
        "id": "EMP125",
        "thName": "พนักงาน 125",
        "enName": "Employee 125",
        "avatarUrl": "https://i.pravatar.cc/150?img=25"
      },
      {
        "id": "EMP126",
        "thName": "พนักงาน 126",
        "enName": "Employee 126",
        "avatarUrl": "https://i.pravatar.cc/150?img=26"
      },
      {
        "id": "EMP127",
        "thName": "พนักงาน 127",
        "enName": "Employee 127",
        "avatarUrl": "https://i.pravatar.cc/150?img=27"
      },
      {
        "id": "EMP128",
        "thName": "พนักงาน 128",
        "enName": "Employee 128",
        "avatarUrl": "https://i.pravatar.cc/150?img=28"
      },
      {
        "id": "EMP129",
        "thName": "พนักงาน 129",
        "enName": "Employee 129",
        "avatarUrl": "https://i.pravatar.cc/150?img=29"
      },
      {
        "id": "EMP130",
        "thName": "พนักงาน 130",
        "enName": "Employee 130",
        "avatarUrl": "https://i.pravatar.cc/150?img=30"
      },
      {
        "id": "EMP131",
        "thName": "พนักงาน 131",
        "enName": "Employee 131",
        "avatarUrl": "https://i.pravatar.cc/150?img=31"
      },
      {
        "id": "EMP132",
        "thName": "พนักงาน 132",
        "enName": "Employee 132",
        "avatarUrl": "https://i.pravatar.cc/150?img=32"
      },
      {
        "id": "EMP133",
        "thName": "พนักงาน 133",
        "enName": "Employee 133",
        "avatarUrl": "https://i.pravatar.cc/150?img=33"
      },
      {
        "id": "EMP134",
        "thName": "พนักงาน 134",
        "enName": "Employee 134",
        "avatarUrl": "https://i.pravatar.cc/150?img=34"
      },
      {
        "id": "EMP135",
        "thName": "พนักงาน 135",
        "enName": "Employee 135",
        "avatarUrl": "https://i.pravatar.cc/150?img=35"
      },
      {
        "id": "EMP136",
        "thName": "พนักงาน 136",
        "enName": "Employee 136",
        "avatarUrl": "https://i.pravatar.cc/150?img=36"
      },
      {
        "id": "EMP137",
        "thName": "พนักงาน 137",
        "enName": "Employee 137",
        "avatarUrl": "https://i.pravatar.cc/150?img=37"
      },
      {
        "id": "EMP138",
        "thName": "พนักงาน 138",
        "enName": "Employee 138",
        "avatarUrl": "https://i.pravatar.cc/150?img=38"
      },
      {
        "id": "EMP139",
        "thName": "พนักงาน 139",
        "enName": "Employee 139",
        "avatarUrl": "https://i.pravatar.cc/150?img=39"
      },
      {
        "id": "EMP140",
        "thName": "พนักงาน 140",
        "enName": "Employee 140",
        "avatarUrl": "https://i.pravatar.cc/150?img=40"
      },
      {
        "id": "EMP141",
        "thName": "พนักงาน 141",
        "enName": "Employee 141",
        "avatarUrl": "https://i.pravatar.cc/150?img=41"
      },
      {
        "id": "EMP142",
        "thName": "พนักงาน 142",
        "enName": "Employee 142",
        "avatarUrl": "https://i.pravatar.cc/150?img=42"
      },
      {
        "id": "EMP143",
        "thName": "พนักงาน 143",
        "enName": "Employee 143",
        "avatarUrl": "https://i.pravatar.cc/150?img=43"
      },
      {
        "id": "EMP144",
        "thName": "พนักงาน 144",
        "enName": "Employee 144",
        "avatarUrl": "https://i.pravatar.cc/150?img=44"
      },
      {
        "id": "EMP145",
        "thName": "พนักงาน 145",
        "enName": "Employee 145",
        "avatarUrl": "https://i.pravatar.cc/150?img=45"
      },
      {
        "id": "EMP146",
        "thName": "พนักงาน 146",
        "enName": "Employee 146",
        "avatarUrl": "https://i.pravatar.cc/150?img=46"
      },
      {
        "id": "EMP147",
        "thName": "พนักงาน 147",
        "enName": "Employee 147",
        "avatarUrl": "https://i.pravatar.cc/150?img=47"
      },
      {
        "id": "EMP148",
        "thName": "พนักงาน 148",
        "enName": "Employee 148",
        "avatarUrl": "https://i.pravatar.cc/150?img=48"
      },
      {
        "id": "EMP149",
        "thName": "พนักงาน 149",
        "enName": "Employee 149",
        "avatarUrl": "https://i.pravatar.cc/150?img=49"
      },
      {
        "id": "EMP150",
        "thName": "พนักงาน 150",
        "enName": "Employee 150",
        "avatarUrl": "https://i.pravatar.cc/150?img=50"
      },
      {
        "id": "EMP151",
        "thName": "พนักงาน 151",
        "enName": "Employee 151",
        "avatarUrl": "https://i.pravatar.cc/150?img=51"
      },
      {
        "id": "EMP152",
        "thName": "พนักงาน 152",
        "enName": "Employee 152",
        "avatarUrl": "https://i.pravatar.cc/150?img=52"
      },
      {
        "id": "EMP153",
        "thName": "พนักงาน 153",
        "enName": "Employee 153",
        "avatarUrl": "https://i.pravatar.cc/150?img=53"
      },
      {
        "id": "EMP154",
        "thName": "พนักงาน 154",
        "enName": "Employee 154",
        "avatarUrl": "https://i.pravatar.cc/150?img=54"
      },
      {
        "id": "EMP155",
        "thName": "พนักงาน 155",
        "enName": "Employee 155",
        "avatarUrl": "https://i.pravatar.cc/150?img=55"
      },
      {
        "id": "EMP156",
        "thName": "พนักงาน 156",
        "enName": "Employee 156",
        "avatarUrl": "https://i.pravatar.cc/150?img=56"
      },
      {
        "id": "EMP157",
        "thName": "พนักงาน 157",
        "enName": "Employee 157",
        "avatarUrl": "https://i.pravatar.cc/150?img=57"
      },
      {
        "id": "EMP158",
        "thName": "พนักงาน 158",
        "enName": "Employee 158",
        "avatarUrl": "https://i.pravatar.cc/150?img=58"
      },
      {
        "id": "EMP159",
        "thName": "พนักงาน 159",
        "enName": "Employee 159",
        "avatarUrl": "https://i.pravatar.cc/150?img=59"
      },
      {
        "id": "EMP160",
        "thName": "พนักงาน 160",
        "enName": "Employee 160",
        "avatarUrl": "https://i.pravatar.cc/150?img=60"
      },
      {
        "id": "EMP161",
        "thName": "พนักงาน 161",
        "enName": "Employee 161",
        "avatarUrl": "https://i.pravatar.cc/150?img=61"
      },
      {
        "id": "EMP162",
        "thName": "พนักงาน 162",
        "enName": "Employee 162",
        "avatarUrl": "https://i.pravatar.cc/150?img=62"
      },
      {
        "id": "EMP163",
        "thName": "พนักงาน 163",
        "enName": "Employee 163",
        "avatarUrl": "https://i.pravatar.cc/150?img=63"
      },
      {
        "id": "EMP164",
        "thName": "พนักงาน 164",
        "enName": "Employee 164",
        "avatarUrl": "https://i.pravatar.cc/150?img=64"
      },
      {
        "id": "EMP165",
        "thName": "พนักงาน 165",
        "enName": "Employee 165",
        "avatarUrl": "https://i.pravatar.cc/150?img=65"
      },
      {
        "id": "EMP166",
        "thName": "พนักงาน 166",
        "enName": "Employee 166",
        "avatarUrl": "https://i.pravatar.cc/150?img=66"
      },
      {
        "id": "EMP167",
        "thName": "พนักงาน 167",
        "enName": "Employee 167",
        "avatarUrl": "https://i.pravatar.cc/150?img=67"
      },
      {
        "id": "EMP168",
        "thName": "พนักงาน 168",
        "enName": "Employee 168",
        "avatarUrl": "https://i.pravatar.cc/150?img=68"
      },
      {
        "id": "EMP169",
        "thName": "พนักงาน 169",
        "enName": "Employee 169",
        "avatarUrl": "https://i.pravatar.cc/150?img=69"
      },
      {
        "id": "EMP170",
        "thName": "พนักงาน 170",
        "enName": "Employee 170",
        "avatarUrl": "https://i.pravatar.cc/150?img=70"
      },
      {
        "id": "EMP171",
        "thName": "พนักงาน 171",
        "enName": "Employee 171",
        "avatarUrl": "https://i.pravatar.cc/150?img=71"
      },
      {
        "id": "EMP172",
        "thName": "พนักงาน 172",
        "enName": "Employee 172",
        "avatarUrl": "https://i.pravatar.cc/150?img=72"
      },
      {
        "id": "EMP173",
        "thName": "พนักงาน 173",
        "enName": "Employee 173",
        "avatarUrl": "https://i.pravatar.cc/150?img=73"
      },
      {
        "id": "EMP174",
        "thName": "พนักงาน 174",
        "enName": "Employee 174",
        "avatarUrl": "https://i.pravatar.cc/150?img=74"
      },
      {
        "id": "EMP175",
        "thName": "พนักงาน 175",
        "enName": "Employee 175",
        "avatarUrl": "https://i.pravatar.cc/150?img=75"
      },
      {
        "id": "EMP176",
        "thName": "พนักงาน 176",
        "enName": "Employee 176",
        "avatarUrl": "https://i.pravatar.cc/150?img=76"
      },
      {
        "id": "EMP177",
        "thName": "พนักงาน 177",
        "enName": "Employee 177",
        "avatarUrl": "https://i.pravatar.cc/150?img=77"
      },
      {
        "id": "EMP178",
        "thName": "พนักงาน 178",
        "enName": "Employee 178",
        "avatarUrl": "https://i.pravatar.cc/150?img=78"
      },
      {
        "id": "EMP179",
        "thName": "พนักงาน 179",
        "enName": "Employee 179",
        "avatarUrl": "https://i.pravatar.cc/150?img=79"
      },
      {
        "id": "EMP180",
        "thName": "พนักงาน 180",
        "enName": "Employee 180",
        "avatarUrl": "https://i.pravatar.cc/150?img=80"
      },
      {
        "id": "EMP181",
        "thName": "พนักงาน 181",
        "enName": "Employee 181",
        "avatarUrl": "https://i.pravatar.cc/150?img=81"
      },
      {
        "id": "EMP182",
        "thName": "พนักงาน 182",
        "enName": "Employee 182",
        "avatarUrl": "https://i.pravatar.cc/150?img=82"
      },
      {
        "id": "EMP183",
        "thName": "พนักงาน 183",
        "enName": "Employee 183",
        "avatarUrl": "https://i.pravatar.cc/150?img=83"
      },
      {
        "id": "EMP184",
        "thName": "พนักงาน 184",
        "enName": "Employee 184",
        "avatarUrl": "https://i.pravatar.cc/150?img=84"
      },
      {
        "id": "EMP185",
        "thName": "พนักงาน 185",
        "enName": "Employee 185",
        "avatarUrl": "https://i.pravatar.cc/150?img=85"
      },
      {
        "id": "EMP186",
        "thName": "พนักงาน 186",
        "enName": "Employee 186",
        "avatarUrl": "https://i.pravatar.cc/150?img=86"
      },
      {
        "id": "EMP187",
        "thName": "พนักงาน 187",
        "enName": "Employee 187",
        "avatarUrl": "https://i.pravatar.cc/150?img=87"
      },
      {
        "id": "EMP188",
        "thName": "พนักงาน 188",
        "enName": "Employee 188",
        "avatarUrl": "https://i.pravatar.cc/150?img=88"
      },
      {
        "id": "EMP189",
        "thName": "พนักงาน 189",
        "enName": "Employee 189",
        "avatarUrl": "https://i.pravatar.cc/150?img=89"
      },
      {
        "id": "EMP190",
        "thName": "พนักงาน 190",
        "enName": "Employee 190",
        "avatarUrl": "https://i.pravatar.cc/150?img=90"
      },
      {
        "id": "EMP191",
        "thName": "พนักงาน 191",
        "enName": "Employee 191",
        "avatarUrl": "https://i.pravatar.cc/150?img=91"
      },
      {
        "id": "EMP192",
        "thName": "พนักงาน 192",
        "enName": "Employee 192",
        "avatarUrl": "https://i.pravatar.cc/150?img=92"
      },
      {
        "id": "EMP193",
        "thName": "พนักงาน 193",
        "enName": "Employee 193",
        "avatarUrl": "https://i.pravatar.cc/150?img=93"
      },
      {
        "id": "EMP194",
        "thName": "พนักงาน 194",
        "enName": "Employee 194",
        "avatarUrl": "https://i.pravatar.cc/150?img=94"
      },
      {
        "id": "EMP195",
        "thName": "พนักงาน 195",
        "enName": "Employee 195",
        "avatarUrl": "https://i.pravatar.cc/150?img=95"
      },
      {
        "id": "EMP196",
        "thName": "พนักงาน 196",
        "enName": "Employee 196",
        "avatarUrl": "https://i.pravatar.cc/150?img=96"
      },
      {
        "id": "EMP197",
        "thName": "พนักงาน 197",
        "enName": "Employee 197",
        "avatarUrl": "https://i.pravatar.cc/150?img=97"
      },
      {
        "id": "EMP198",
        "thName": "พนักงาน 198",
        "enName": "Employee 198",
        "avatarUrl": "https://i.pravatar.cc/150?img=98"
      },
      {
        "id": "EMP199",
        "thName": "พนักงาน 199",
        "enName": "Employee 199",
        "avatarUrl": "https://i.pravatar.cc/150?img=99"
      },
      {
        "id": "EMP200",
        "thName": "พนักงาน 200",
        "enName": "Employee 200",
        "avatarUrl": "https://i.pravatar.cc/150?img=100"
      },
      {
        "id": "EMP201",
        "thName": "พนักงาน 201",
        "enName": "Employee 201",
        "avatarUrl": "https://i.pravatar.cc/150?img=1"
      },
      {
        "id": "EMP202",
        "thName": "พนักงาน 202",
        "enName": "Employee 202",
        "avatarUrl": "https://i.pravatar.cc/150?img=2"
      },
      {
        "id": "EMP203",
        "thName": "พนักงาน 203",
        "enName": "Employee 203",
        "avatarUrl": "https://i.pravatar.cc/150?img=3"
      },
      {
        "id": "EMP204",
        "thName": "พนักงาน 204",
        "enName": "Employee 204",
        "avatarUrl": "https://i.pravatar.cc/150?img=4"
      },
      {
        "id": "EMP205",
        "thName": "พนักงาน 205",
        "enName": "Employee 205",
        "avatarUrl": "https://i.pravatar.cc/150?img=5"
      },
      {
        "id": "EMP206",
        "thName": "พนักงาน 206",
        "enName": "Employee 206",
        "avatarUrl": "https://i.pravatar.cc/150?img=6"
      },
      {
        "id": "EMP207",
        "thName": "พนักงาน 207",
        "enName": "Employee 207",
        "avatarUrl": "https://i.pravatar.cc/150?img=7"
      },
      {
        "id": "EMP208",
        "thName": "พนักงาน 208",
        "enName": "Employee 208",
        "avatarUrl": "https://i.pravatar.cc/150?img=8"
      },
      {
        "id": "EMP209",
        "thName": "พนักงาน 209",
        "enName": "Employee 209",
        "avatarUrl": "https://i.pravatar.cc/150?img=9"
      },
      {
        "id": "EMP210",
        "thName": "พนักงาน 210",
        "enName": "Employee 210",
        "avatarUrl": "https://i.pravatar.cc/150?img=10"
      },
      {
        "id": "EMP211",
        "thName": "พนักงาน 211",
        "enName": "Employee 211",
        "avatarUrl": "https://i.pravatar.cc/150?img=11"
      },
      {
        "id": "EMP212",
        "thName": "พนักงาน 212",
        "enName": "Employee 212",
        "avatarUrl": "https://i.pravatar.cc/150?img=12"
      },
      {
        "id": "EMP213",
        "thName": "พนักงาน 213",
        "enName": "Employee 213",
        "avatarUrl": "https://i.pravatar.cc/150?img=13"
      },
      {
        "id": "EMP214",
        "thName": "พนักงาน 214",
        "enName": "Employee 214",
        "avatarUrl": "https://i.pravatar.cc/150?img=14"
      },
      {
        "id": "EMP215",
        "thName": "พนักงาน 215",
        "enName": "Employee 215",
        "avatarUrl": "https://i.pravatar.cc/150?img=15"
      },
      {
        "id": "EMP216",
        "thName": "พนักงาน 216",
        "enName": "Employee 216",
        "avatarUrl": "https://i.pravatar.cc/150?img=16"
      },
      {
        "id": "EMP217",
        "thName": "พนักงาน 217",
        "enName": "Employee 217",
        "avatarUrl": "https://i.pravatar.cc/150?img=17"
      },
      {
        "id": "EMP218",
        "thName": "พนักงาน 218",
        "enName": "Employee 218",
        "avatarUrl": "https://i.pravatar.cc/150?img=18"
      },
      {
        "id": "EMP219",
        "thName": "พนักงาน 219",
        "enName": "Employee 219",
        "avatarUrl": "https://i.pravatar.cc/150?img=19"
      },
      {
        "id": "EMP220",
        "thName": "พนักงาน 220",
        "enName": "Employee 220",
        "avatarUrl": "https://i.pravatar.cc/150?img=20"
      },
      {
        "id": "EMP221",
        "thName": "พนักงาน 221",
        "enName": "Employee 221",
        "avatarUrl": "https://i.pravatar.cc/150?img=21"
      },
      {
        "id": "EMP222",
        "thName": "พนักงาน 222",
        "enName": "Employee 222",
        "avatarUrl": "https://i.pravatar.cc/150?img=22"
      },
      {
        "id": "EMP223",
        "thName": "พนักงาน 223",
        "enName": "Employee 223",
        "avatarUrl": "https://i.pravatar.cc/150?img=23"
      },
      {
        "id": "EMP224",
        "thName": "พนักงาน 224",
        "enName": "Employee 224",
        "avatarUrl": "https://i.pravatar.cc/150?img=24"
      },
      {
        "id": "EMP225",
        "thName": "พนักงาน 225",
        "enName": "Employee 225",
        "avatarUrl": "https://i.pravatar.cc/150?img=25"
      },
      {
        "id": "EMP226",
        "thName": "พนักงาน 226",
        "enName": "Employee 226",
        "avatarUrl": "https://i.pravatar.cc/150?img=26"
      },
      {
        "id": "EMP227",
        "thName": "พนักงาน 227",
        "enName": "Employee 227",
        "avatarUrl": "https://i.pravatar.cc/150?img=27"
      },
      {
        "id": "EMP228",
        "thName": "พนักงาน 228",
        "enName": "Employee 228",
        "avatarUrl": "https://i.pravatar.cc/150?img=28"
      },
      {
        "id": "EMP229",
        "thName": "พนักงาน 229",
        "enName": "Employee 229",
        "avatarUrl": "https://i.pravatar.cc/150?img=29"
      },
      {
        "id": "EMP230",
        "thName": "พนักงาน 230",
        "enName": "Employee 230",
        "avatarUrl": "https://i.pravatar.cc/150?img=30"
      },
      {
        "id": "EMP231",
        "thName": "พนักงาน 231",
        "enName": "Employee 231",
        "avatarUrl": "https://i.pravatar.cc/150?img=31"
      },
      {
        "id": "EMP232",
        "thName": "พนักงาน 232",
        "enName": "Employee 232",
        "avatarUrl": "https://i.pravatar.cc/150?img=32"
      },
      {
        "id": "EMP233",
        "thName": "พนักงาน 233",
        "enName": "Employee 233",
        "avatarUrl": "https://i.pravatar.cc/150?img=33"
      },
      {
        "id": "EMP234",
        "thName": "พนักงาน 234",
        "enName": "Employee 234",
        "avatarUrl": "https://i.pravatar.cc/150?img=34"
      },
      {
        "id": "EMP235",
        "thName": "พนักงาน 235",
        "enName": "Employee 235",
        "avatarUrl": "https://i.pravatar.cc/150?img=35"
      },
      {
        "id": "EMP236",
        "thName": "พนักงาน 236",
        "enName": "Employee 236",
        "avatarUrl": "https://i.pravatar.cc/150?img=36"
      },
      {
        "id": "EMP237",
        "thName": "พนักงาน 237",
        "enName": "Employee 237",
        "avatarUrl": "https://i.pravatar.cc/150?img=37"
      },
      {
        "id": "EMP238",
        "thName": "พนักงาน 238",
        "enName": "Employee 238",
        "avatarUrl": "https://i.pravatar.cc/150?img=38"
      },
      {
        "id": "EMP239",
        "thName": "พนักงาน 239",
        "enName": "Employee 239",
        "avatarUrl": "https://i.pravatar.cc/150?img=39"
      },
      {
        "id": "EMP240",
        "thName": "พนักงาน 240",
        "enName": "Employee 240",
        "avatarUrl": "https://i.pravatar.cc/150?img=40"
      },
      {
        "id": "EMP241",
        "thName": "พนักงาน 241",
        "enName": "Employee 241",
        "avatarUrl": "https://i.pravatar.cc/150?img=41"
      },
      {
        "id": "EMP242",
        "thName": "พนักงาน 242",
        "enName": "Employee 242",
        "avatarUrl": "https://i.pravatar.cc/150?img=42"
      },
      {
        "id": "EMP243",
        "thName": "พนักงาน 243",
        "enName": "Employee 243",
        "avatarUrl": "https://i.pravatar.cc/150?img=43"
      },
      {
        "id": "EMP244",
        "thName": "พนักงาน 244",
        "enName": "Employee 244",
        "avatarUrl": "https://i.pravatar.cc/150?img=44"
      },
      {
        "id": "EMP245",
        "thName": "พนักงาน 245",
        "enName": "Employee 245",
        "avatarUrl": "https://i.pravatar.cc/150?img=45"
      },
      {
        "id": "EMP246",
        "thName": "พนักงาน 246",
        "enName": "Employee 246",
        "avatarUrl": "https://i.pravatar.cc/150?img=46"
      },
      {
        "id": "EMP247",
        "thName": "พนักงาน 247",
        "enName": "Employee 247",
        "avatarUrl": "https://i.pravatar.cc/150?img=47"
      },
      {
        "id": "EMP248",
        "thName": "พนักงาน 248",
        "enName": "Employee 248",
        "avatarUrl": "https://i.pravatar.cc/150?img=48"
      },
      {
        "id": "EMP249",
        "thName": "พนักงาน 249",
        "enName": "Employee 249",
        "avatarUrl": "https://i.pravatar.cc/150?img=49"
      },
      {
        "id": "EMP250",
        "thName": "พนักงาน 250",
        "enName": "Employee 250",
        "avatarUrl": "https://i.pravatar.cc/150?img=50"
      },
      {
        "id": "EMP251",
        "thName": "พนักงาน 251",
        "enName": "Employee 251",
        "avatarUrl": "https://i.pravatar.cc/150?img=51"
      },
      {
        "id": "EMP252",
        "thName": "พนักงาน 252",
        "enName": "Employee 252",
        "avatarUrl": "https://i.pravatar.cc/150?img=52"
      },
      {
        "id": "EMP253",
        "thName": "พนักงาน 253",
        "enName": "Employee 253",
        "avatarUrl": "https://i.pravatar.cc/150?img=53"
      },
      {
        "id": "EMP254",
        "thName": "พนักงาน 254",
        "enName": "Employee 254",
        "avatarUrl": "https://i.pravatar.cc/150?img=54"
      },
      {
        "id": "EMP255",
        "thName": "พนักงาน 255",
        "enName": "Employee 255",
        "avatarUrl": "https://i.pravatar.cc/150?img=55"
      },
      {
        "id": "EMP256",
        "thName": "พนักงาน 256",
        "enName": "Employee 256",
        "avatarUrl": "https://i.pravatar.cc/150?img=56"
      },
      {
        "id": "EMP257",
        "thName": "พนักงาน 257",
        "enName": "Employee 257",
        "avatarUrl": "https://i.pravatar.cc/150?img=57"
      },
      {
        "id": "EMP258",
        "thName": "พนักงาน 258",
        "enName": "Employee 258",
        "avatarUrl": "https://i.pravatar.cc/150?img=58"
      },
      {
        "id": "EMP259",
        "thName": "พนักงาน 259",
        "enName": "Employee 259",
        "avatarUrl": "https://i.pravatar.cc/150?img=59"
      },
      {
        "id": "EMP260",
        "thName": "พนักงาน 260",
        "enName": "Employee 260",
        "avatarUrl": "https://i.pravatar.cc/150?img=60"
      },
      {
        "id": "EMP261",
        "thName": "พนักงาน 261",
        "enName": "Employee 261",
        "avatarUrl": "https://i.pravatar.cc/150?img=61"
      },
      {
        "id": "EMP262",
        "thName": "พนักงาน 262",
        "enName": "Employee 262",
        "avatarUrl": "https://i.pravatar.cc/150?img=62"
      },
      {
        "id": "EMP263",
        "thName": "พนักงาน 263",
        "enName": "Employee 263",
        "avatarUrl": "https://i.pravatar.cc/150?img=63"
      },
      {
        "id": "EMP264",
        "thName": "พนักงาน 264",
        "enName": "Employee 264",
        "avatarUrl": "https://i.pravatar.cc/150?img=64"
      },
      {
        "id": "EMP265",
        "thName": "พนักงาน 265",
        "enName": "Employee 265",
        "avatarUrl": "https://i.pravatar.cc/150?img=65"
      },
      {
        "id": "EMP266",
        "thName": "พนักงาน 266",
        "enName": "Employee 266",
        "avatarUrl": "https://i.pravatar.cc/150?img=66"
      },
      {
        "id": "EMP267",
        "thName": "พนักงาน 267",
        "enName": "Employee 267",
        "avatarUrl": "https://i.pravatar.cc/150?img=67"
      },
      {
        "id": "EMP268",
        "thName": "พนักงาน 268",
        "enName": "Employee 268",
        "avatarUrl": "https://i.pravatar.cc/150?img=68"
      },
      {
        "id": "EMP269",
        "thName": "พนักงาน 269",
        "enName": "Employee 269",
        "avatarUrl": "https://i.pravatar.cc/150?img=69"
      },
      {
        "id": "EMP270",
        "thName": "พนักงาน 270",
        "enName": "Employee 270",
        "avatarUrl": "https://i.pravatar.cc/150?img=70"
      },
      {
        "id": "EMP271",
        "thName": "พนักงาน 271",
        "enName": "Employee 271",
        "avatarUrl": "https://i.pravatar.cc/150?img=71"
      },
      {
        "id": "EMP272",
        "thName": "พนักงาน 272",
        "enName": "Employee 272",
        "avatarUrl": "https://i.pravatar.cc/150?img=72"
      },
      {
        "id": "EMP273",
        "thName": "พนักงาน 273",
        "enName": "Employee 273",
        "avatarUrl": "https://i.pravatar.cc/150?img=73"
      },
      {
        "id": "EMP274",
        "thName": "พนักงาน 274",
        "enName": "Employee 274",
        "avatarUrl": "https://i.pravatar.cc/150?img=74"
      },
      {
        "id": "EMP275",
        "thName": "พนักงาน 275",
        "enName": "Employee 275",
        "avatarUrl": "https://i.pravatar.cc/150?img=75"
      },
      {
        "id": "EMP276",
        "thName": "พนักงาน 276",
        "enName": "Employee 276",
        "avatarUrl": "https://i.pravatar.cc/150?img=76"
      },
      {
        "id": "EMP277",
        "thName": "พนักงาน 277",
        "enName": "Employee 277",
        "avatarUrl": "https://i.pravatar.cc/150?img=77"
      },
      {
        "id": "EMP278",
        "thName": "พนักงาน 278",
        "enName": "Employee 278",
        "avatarUrl": "https://i.pravatar.cc/150?img=78"
      },
      {
        "id": "EMP279",
        "thName": "พนักงาน 279",
        "enName": "Employee 279",
        "avatarUrl": "https://i.pravatar.cc/150?img=79"
      },
      {
        "id": "EMP280",
        "thName": "พนักงาน 280",
        "enName": "Employee 280",
        "avatarUrl": "https://i.pravatar.cc/150?img=80"
      },
      {
        "id": "EMP281",
        "thName": "พนักงาน 281",
        "enName": "Employee 281",
        "avatarUrl": "https://i.pravatar.cc/150?img=81"
      },
      {
        "id": "EMP282",
        "thName": "พนักงาน 282",
        "enName": "Employee 282",
        "avatarUrl": "https://i.pravatar.cc/150?img=82"
      },
      {
        "id": "EMP283",
        "thName": "พนักงาน 283",
        "enName": "Employee 283",
        "avatarUrl": "https://i.pravatar.cc/150?img=83"
      },
      {
        "id": "EMP284",
        "thName": "พนักงาน 284",
        "enName": "Employee 284",
        "avatarUrl": "https://i.pravatar.cc/150?img=84"
      },
      {
        "id": "EMP285",
        "thName": "พนักงาน 285",
        "enName": "Employee 285",
        "avatarUrl": "https://i.pravatar.cc/150?img=85"
      },
      {
        "id": "EMP286",
        "thName": "พนักงาน 286",
        "enName": "Employee 286",
        "avatarUrl": "https://i.pravatar.cc/150?img=86"
      },
      {
        "id": "EMP287",
        "thName": "พนักงาน 287",
        "enName": "Employee 287",
        "avatarUrl": "https://i.pravatar.cc/150?img=87"
      },
      {
        "id": "EMP288",
        "thName": "พนักงาน 288",
        "enName": "Employee 288",
        "avatarUrl": "https://i.pravatar.cc/150?img=88"
      },
      {
        "id": "EMP289",
        "thName": "พนักงาน 289",
        "enName": "Employee 289",
        "avatarUrl": "https://i.pravatar.cc/150?img=89"
      },
      {
        "id": "EMP290",
        "thName": "พนักงาน 290",
        "enName": "Employee 290",
        "avatarUrl": "https://i.pravatar.cc/150?img=90"
      },
      {
        "id": "EMP291",
        "thName": "พนักงาน 291",
        "enName": "Employee 291",
        "avatarUrl": "https://i.pravatar.cc/150?img=91"
      },
      {
        "id": "EMP292",
        "thName": "พนักงาน 292",
        "enName": "Employee 292",
        "avatarUrl": "https://i.pravatar.cc/150?img=92"
      },
      {
        "id": "EMP293",
        "thName": "พนักงาน 293",
        "enName": "Employee 293",
        "avatarUrl": "https://i.pravatar.cc/150?img=93"
      },
      {
        "id": "EMP294",
        "thName": "พนักงาน 294",
        "enName": "Employee 294",
        "avatarUrl": "https://i.pravatar.cc/150?img=94"
      },
      {
        "id": "EMP295",
        "thName": "พนักงาน 295",
        "enName": "Employee 295",
        "avatarUrl": "https://i.pravatar.cc/150?img=95"
      },
      {
        "id": "EMP296",
        "thName": "พนักงาน 296",
        "enName": "Employee 296",
        "avatarUrl": "https://i.pravatar.cc/150?img=96"
      },
      {
        "id": "EMP297",
        "thName": "พนักงาน 297",
        "enName": "Employee 297",
        "avatarUrl": "https://i.pravatar.cc/150?img=97"
      },
      {
        "id": "EMP298",
        "thName": "พนักงาน 298",
        "enName": "Employee 298",
        "avatarUrl": "https://i.pravatar.cc/150?img=98"
      },
      {
        "id": "EMP299",
        "thName": "พนักงาน 299",
        "enName": "Employee 299",
        "avatarUrl": "https://i.pravatar.cc/150?img=99"
      },
      {
        "id": "EMP300",
        "thName": "พนักงาน 300",
        "enName": "Employee 300",
        "avatarUrl": "https://i.pravatar.cc/150?img=100"
      }
    ]
  };

  return Response(
    requestOptions: RequestOptions(path: '/system/role/all-user/1'),
    data: mockData,
    statusCode: 200,
  );
}

class EditRole extends StatefulWidget {
  final RoleSystem roleInfo;

  const EditRole({
    super.key,
    required this.roleInfo,
  });

  @override
  State<EditRole> createState() => _EditRoleState();
}

class _EditRoleState extends State<EditRole> {

  late RoleSystem _role;

  Timer? _debounce;
  Timer? _popupDebounce;

  late TextEditingController _nameController;
  late TextEditingController _searchController;
  final TextEditingController _popupSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late String _originalValue;
  late Color _roleColor;

  List<Member> _filteredMembers = [];
  List<Member> allMembers = [];
  List<Member> addMembers = [];
  List<Member> popupFilteredMembers = [];
  bool _popupLoaded = false;

  // ---------- lifecycle ----------
  @override
  void initState() {
    super.initState();
    _role = widget.roleInfo.copyWith(
      members: List.from(widget.roleInfo.members),
    );
    _originalValue = _role.roleName;
    _nameController = TextEditingController(text: _originalValue);
    _nameController.addListener(() {
      setState(() {});
    });
    _searchController = TextEditingController();
    _roleColor = _role.roleColor != null ? _hexToColor(_role.roleColor!) : const Color(0xFFFFA726);
    _filteredMembers = _role.members;
  }


  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _popupSearchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _popupDebounce?.cancel();
    super.dispose();
  }

  // ---------- utils ----------
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  // ---------- search member ----------
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final key = value.trim().toLowerCase();

      setState(() {
        _filteredMembers = key.isEmpty ? _role.members : _role.members.where((m) => m.thName.toLowerCase().contains(key) || m.enName.toLowerCase().contains(key)).toList();
      });
    });
  }

  void _filterPopupMembers(String key, void Function(void Function()) setStatePopup) {
    final searchKey = key.trim().toLowerCase();

    setStatePopup(() {
      popupFilteredMembers = allMembers.where((m) {

        final th = m.thName.trim().toLowerCase();
        final en = m.enName.trim().toLowerCase();

        final matchSearch = searchKey.isEmpty || th.contains(searchKey) || en.contains(searchKey);

        final notInRole = !_role.members.any((e) => e.id.trim() == m.id.trim());

        return matchSearch && notInRole;

      }).toList();
    });
  }


  String getPermission() {
    switch (_role.type) {
      case RoleType.admin:
        return 'ผู้ดูแลระบบ';
      case RoleType.hr:
        return 'ฝ่ายบุคคล';
      case RoleType.mainRole:
        return 'ตำแหน่งหลัก';
      case RoleType.specialRole:
        return 'ตำแหน่งเพิ่มเติม';
    }
  }

  RoleType permissionToRoleType(String val) {
    switch (val) {
      case 'ผู้ดูแลระบบ':
        return RoleType.admin;
      case 'ฝ่ายบุคคล':
        return RoleType.hr;
      case 'ตำแหน่งหลัก':
        return RoleType.mainRole;
      case 'ตำแหน่งเพิ่มเติม':
      default:
        return RoleType.specialRole;
    }
  }


  String roleTypeToApi(RoleType type) {
    switch (type) {
      case RoleType.admin:
        return 'admin';
      case RoleType.hr:
        return 'hr';
      case RoleType.mainRole:
        return 'main';
      case RoleType.specialRole:
        return 'special';
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'แก้ไข: ${_role.roleName}',
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 10, right: 10, top: 20, bottom: 10),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 17,
                          children: [
                            /// ===== Role name =====
                            Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E3E3),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                spacing: 13,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/tag.svg',
                                        height: 15,
                                        width: 15,
                                      ),
                                      const Text('ตำแหน่ง'),
                                    ],
                                  ),
                                  Row(
                                    spacing: 13,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          focusNode: _focusNode,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            hintText: 'กรุณาระบุชื่อตำแหน่ง',
                                            hintStyle: const TextStyle(
                                              color: Colors.black38,
                                              fontSize: 14,
                                            ),
                                            isDense: true,
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: InkWell(
                                              customBorder: const CircleBorder(),
                                              onTap: () {
                                                _nameController.clear();
                                                FocusScope.of(context).unfocus();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  CupertinoIcons.xmark_circle_fill,
                                                  size: 17,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSubmitted: (val) {
                                            final newName = val.trim();

                                            if (newName.isEmpty) return;

                                            setState(() {
                                              _role = _role.copyWith(roleName: newName);
                                            });

                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          ColorPickerPopup(
                                            selected: _roleColor,
                                            onSubmit: (color) {
                                              setState(() {
                                                _roleColor = color;
                                              });
                                            },
                                          ).showPopup(context);
                                        },
                                        child: Container(
                                          width: 33,
                                          height: 33,
                                          decoration: BoxDecoration(
                                            color: _roleColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF606060),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// ===== Delete role =====
                            SeparatorCard(
                                separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                children: [
                                  IconTextButton(onPressed: () {
                                    FloatingPopup(
                                        title: 'ลบตำแหน่ง',
                                        description: 'คุณยืนยันที่จะลบตำแหน่ง ${_role.roleName} หรือไม่ การดำเนินการนี้จะไม่สามารถย้อนกลับมาได้อีก',
                                        buttons: (parent, context1) => [
                                          FloatingPopupButton(
                                            text: 'ยกเลิก',
                                            foregroundColor: Colors.white,
                                            backgroundColor: AppColors.primaryColor,
                                            onPressed: () {
                                              Navigator.of(context1).pop();
                                            },
                                          ),
                                          FloatingServicePopupButton(
                                            text: 'ยันยัน',
                                            foregroundColor: Colors.red,
                                            request: () => RoleManagementService().deleteRole(_role),
                                            setError: parent,
                                            onSuccess: () {
                                              Navigator.of(context1).pop();

                                              Navigator.pop(context, {
                                                'status': 1,
                                              });
                                            },
                                          )
                                        ]
                                    ).showPopup(context);
                                  }, arrow: false, color: Colors.red, icon: 'icon_delete.svg', label: 'ลบตำแหน่ง')
                                ]
                            ),
                            /// กำหนดสิทธิ์การเข้าถึง
                            // SeparatorCard(
                            //   separatorPadding:
                            //   const EdgeInsets.only(left: 45, right: 15),
                            //   children: [
                            //     IconTextButton(
                            //       arrow: false,
                            //       icon: 'icon_delete.svg',
                            //       label: 'ระดับสิทธิ์การเข้าถึง',
                            //       onPressed: ()  {
                            //         OptionPopup(
                            //           title: 'ระดับสิทธิ์การเข้าถึง',
                            //           options: ['ตำแหน่งหลัก', 'ตำแหน่งเพิ่มเติม', 'ผู้ดูแลระบบ','ฝ่ายบุคคล'],
                            //           buttonLabel: 'บันทึก',
                            //           maxHeight: 700,
                            //           fit: FlexFit.tight,
                            //           selected: getPermission(),
                            //           onSubmit: (val) {
                            //             final newType = permissionToRoleType(val);
                            //
                            //             if (newType == _role.type) return;
                            //
                            //             setState(() {
                            //               _role = _role.copyWith(type: newType);
                            //             });
                            //           },
                            //
                            //         ).showPopup(context);
                            //       },
                            //     ),
                            //   ],
                            // ),

                            /// ===== Search & Add =====
                            Column(
                              spacing: 6,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/icon_user.svg',
                                      height: 15,
                                      width: 15,
                                    ),
                                    Text('สมาชิกในสังกัด (${_filteredMembers.length})'),
                                  ],
                                ),
                                /// ==== Searchbar ====
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(50),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(50),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                                                width: 1,
                                              ),
                                            ),
                                            hint: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 10,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/search.svg',
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                Text('ค้นหาผู้ใช้...',
                                                  style: TextStyle(
                                                      color: Color(0xFF7D7D7D),
                                                      fontSize: 15
                                                  )
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 55,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.all(0),
                                            side: const BorderSide(
                                              color: Color(0xFF7D7D7D),
                                              width: 1,
                                            ),
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/images/create_user.svg',
                                            colorFilter: ColorFilter.mode(Color(0xFF7D7D7D), BlendMode.srcIn),
                                          ),


                                          onPressed: () async {

                                            _popupSearchController.clear();

                                            addMembers = [];
                                            popupFilteredMembers = [];
                                            _popupLoaded = false;

                                            PushPopup(
                                              title: 'เพิ่มสมาชิก',
                                              buttonLabel: 'เพิ่ม',
                                              fit: FlexFit.tight,
                                              scroll: false,
                                              buttonAction: (context) {
                                                setState(() {
                                                  final newMembers = List<Member>.from(_role.members);

                                                  for (var m in addMembers) {
                                                    if (!newMembers.any((e) => e.id == m.id)) {
                                                      newMembers.add(m);
                                                    }
                                                  }

                                                  _role = _role.copyWith(members: newMembers);

                                                  _filteredMembers = _role.members;
                                                });


                                                Navigator.pop(context);
                                              },
                                              builder: (_) => StatefulBuilder(
                                                builder: (context, setStatePopup) {

                                                  return Column(
                                                    spacing: 16,
                                                    children: [
                                                      TextField(
                                                        controller: _popupSearchController,
                                                        onChanged: (val) {

                                                          if (_popupDebounce?.isActive ?? false) {
                                                            _popupDebounce!.cancel();
                                                          }

                                                          _popupDebounce = Timer(
                                                            const Duration(milliseconds: 400),
                                                                () => _filterPopupMembers(val, setStatePopup),
                                                          );

                                                        },
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(50),
                                                            borderSide: const BorderSide(
                                                              color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                                                              width: 1,
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(50),
                                                            borderSide: const BorderSide(
                                                              color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                                                              width: 1,
                                                            ),
                                                          ),
                                                          hint: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            spacing: 10,
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/search.svg',
                                                                width: 15,
                                                                height: 15,
                                                              ),
                                                              Text('ค้นหาตำแหน่ง...',
                                                                style: TextStyle(
                                                                    color: Color(0xFF7D7D7D),
                                                                    fontSize: 15
                                                                )
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      ServiceLoader(
                                                        request: () => RoleManagementService().getUser(_role),
                                                        // request: () => getMemberAll(),
                                                        onSuccess: (res) {

                                                          final map = res as Map<String, dynamic>;
                                                          final list = map['members'] as List;

                                                          final loaded =
                                                          list.map((e) => Member.fromJson(e)).toList();

                                                          allMembers = loaded;

                                                          _filterPopupMembers(
                                                            _popupSearchController.text,
                                                            setStatePopup,
                                                          );
                                                        },
                                                        builder: () => Expanded(
                                                          child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(20),
                                                              child: SingleChildScrollView(
                                                                child: SeparatorCard(
                                                                  separatorPadding: EdgeInsetsGeometry.only(left: 68, right: 15),
                                                                  children: [
                                                                    ...popupFilteredMembers.map((m) {
                                                                      return UserCancelCheckbox(
                                                                        icon: Image.network(m.avatarUrl),
                                                                        title: m.thName,
                                                                        subTitle: m.enName,
                                                                        checkBox: true,
                                                                        value: addMembers.any((e) => e.id == m.id),
                                                                        onChanged: (val) {
                                                                          setStatePopup(() {
                                                                            if (val) {
                                                                              if (!addMembers.any((e) => e.id == m.id)) {
                                                                                addMembers.add(m);
                                                                              }
                                                                            } else {
                                                                              addMembers.removeWhere((e) => e.id == m.id);
                                                                            }
                                                                          });
                                                                        },
                                                                      );
                                                                    })
                                                                  ],
                                                                ),
                                                              )
                                                          ),
                                                        )
                                                      )
                                                    ],
                                                  );
                                                }
                                              )
                                            ).showPopup(context);
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                )
                              ],
                            ),

                            /// ===== Member list =====
                            if (_filteredMembers.isNotEmpty)
                              SeparatorCard(
                                separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 68),
                                children: [
                                  ..._filteredMembers.map((m) {
                                    return UserCancelCheckbox(
                                      icon: Image.network(m.avatarUrl, fit: BoxFit.cover,),
                                      title: m.thName,
                                      subTitle: m.enName,
                                      checkBox: false,
                                      onCancel: () {
                                        setState(() {
                                          final newMembers = List<Member>.from(_role.members)
                                            ..removeWhere((e) => e.id == m.id);

                                          _role = _role.copyWith(members: newMembers);

                                          _filteredMembers = _role.members;
                                        });
                                      }
                                    );
                                  }),
                                ],
                              ),
                          ],
                        ),
                      )
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ServiceUpdater(
                      request: () => RoleManagementService().updateRole(
                        _role.copyWith(
                          roleName: _nameController.text.trim(),
                          roleColor:
                          _roleColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2),
                        ),
                      ),
                      onSuccess: () {
                        final updatedRole = _role.copyWith(
                          roleName: _nameController.text.trim(),
                          roleColor:
                          _roleColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2),
                        );

                        Navigator.pop(context, updatedRole);
                      },
                      builder: (trigger, state, errorMessage) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: (state != ServiceUpdatorState.loading &&
                                    _nameController.text.trim().isNotEmpty)
                                    ? () => trigger()
                                    : null,
                                icon: SvgPicture.asset(
                                  'assets/images/save.svg',
                                  height: 18,
                                  width: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: Row(
                                  spacing: 10,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'บันทึก',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (state == ServiceUpdatorState.loading)
                                      CupertinoActivityIndicator(color: Colors.white)
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.grey,
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: (state == ServiceUpdatorState.error) ?
                              Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
                                style: TextStyle(
                                    color: Colors.red
                                )
                              ) : SizedBox()
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ],
            )
          ),
        )
      ),
    );
  }
}
