#!/usr/bin/env python3
"""Generates lib/core/countries/countries_data.dart.
Run:  python3 tool/gen_countries.py
Format per line: ISO2|dial code|Arabic name|English name
Pinned first (in this order): JO, SA, EG. The rest follow alphabetically (en).
"""
import pathlib

DATA = """
AF|93|أفغانستان|Afghanistan
AL|355|ألبانيا|Albania
DZ|213|الجزائر|Algeria
AS|1684|ساموا الأمريكية|American Samoa
AD|376|أندورا|Andorra
AO|244|أنغولا|Angola
AI|1264|أنغويلا|Anguilla
AG|1268|أنتيغوا وبربودا|Antigua and Barbuda
AR|54|الأرجنتين|Argentina
AM|374|أرمينيا|Armenia
AW|297|أروبا|Aruba
AU|61|أستراليا|Australia
AT|43|النمسا|Austria
AZ|994|أذربيجان|Azerbaijan
BS|1242|الباهاما|Bahamas
BH|973|البحرين|Bahrain
BD|880|بنغلاديش|Bangladesh
BB|1246|بربادوس|Barbados
BY|375|بيلاروسيا|Belarus
BE|32|بلجيكا|Belgium
BZ|501|بليز|Belize
BJ|229|بنين|Benin
BM|1441|برمودا|Bermuda
BT|975|بوتان|Bhutan
BO|591|بوليفيا|Bolivia
BA|387|البوسنة والهرسك|Bosnia and Herzegovina
BW|267|بوتسوانا|Botswana
BR|55|البرازيل|Brazil
VG|1284|جزر العذراء البريطانية|British Virgin Islands
BN|673|بروناي|Brunei
BG|359|بلغاريا|Bulgaria
BF|226|بوركينا فاسو|Burkina Faso
BI|257|بوروندي|Burundi
KH|855|كمبوديا|Cambodia
CM|237|الكاميرون|Cameroon
CA|1|كندا|Canada
CV|238|الرأس الأخضر|Cape Verde
KY|1345|جزر كايمان|Cayman Islands
CF|236|جمهورية أفريقيا الوسطى|Central African Republic
TD|235|تشاد|Chad
CL|56|تشيلي|Chile
CN|86|الصين|China
CO|57|كولومبيا|Colombia
KM|269|جزر القمر|Comoros
CG|242|الكونغو|Congo
CD|243|الكونغو الديمقراطية|Congo (DRC)
CR|506|كوستاريكا|Costa Rica
CI|225|ساحل العاج|Côte d'Ivoire
HR|385|كرواتيا|Croatia
CU|53|كوبا|Cuba
CW|599|كوراساو|Curaçao
CY|357|قبرص|Cyprus
CZ|420|التشيك|Czechia
DK|45|الدنمارك|Denmark
DJ|253|جيبوتي|Djibouti
DM|1767|دومينيكا|Dominica
DO|1809|جمهورية الدومينيكان|Dominican Republic
EC|593|الإكوادور|Ecuador
SV|503|السلفادور|El Salvador
GQ|240|غينيا الاستوائية|Equatorial Guinea
ER|291|إريتريا|Eritrea
EE|372|إستونيا|Estonia
SZ|268|إسواتيني|Eswatini
ET|251|إثيوبيا|Ethiopia
FK|500|جزر فوكلاند|Falkland Islands
FO|298|جزر فارو|Faroe Islands
FJ|679|فيجي|Fiji
FI|358|فنلندا|Finland
FR|33|فرنسا|France
GF|594|غويانا الفرنسية|French Guiana
PF|689|بولينيزيا الفرنسية|French Polynesia
GA|241|الغابون|Gabon
GM|220|غامبيا|Gambia
GE|995|جورجيا|Georgia
DE|49|ألمانيا|Germany
GH|233|غانا|Ghana
GI|350|جبل طارق|Gibraltar
GR|30|اليونان|Greece
GL|299|غرينلاند|Greenland
GD|1473|غرينادا|Grenada
GP|590|غوادلوب|Guadeloupe
GU|1671|غوام|Guam
GT|502|غواتيمالا|Guatemala
GN|224|غينيا|Guinea
GW|245|غينيا بيساو|Guinea-Bissau
GY|592|غيانا|Guyana
HT|509|هايتي|Haiti
HN|504|هندوراس|Honduras
HK|852|هونغ كونغ|Hong Kong
HU|36|المجر|Hungary
IS|354|آيسلندا|Iceland
IN|91|الهند|India
ID|62|إندونيسيا|Indonesia
IR|98|إيران|Iran
IQ|964|العراق|Iraq
IE|353|أيرلندا|Ireland
IL|972|إسرائيل|Israel
IT|39|إيطاليا|Italy
JM|1876|جامايكا|Jamaica
JP|81|اليابان|Japan
KZ|7|كازاخستان|Kazakhstan
KE|254|كينيا|Kenya
KI|686|كيريباتي|Kiribati
XK|383|كوسوفو|Kosovo
KW|965|الكويت|Kuwait
KG|996|قيرغيزستان|Kyrgyzstan
LA|856|لاوس|Laos
LV|371|لاتفيا|Latvia
LB|961|لبنان|Lebanon
LS|266|ليسوتو|Lesotho
LR|231|ليبيريا|Liberia
LY|218|ليبيا|Libya
LI|423|ليختنشتاين|Liechtenstein
LT|370|ليتوانيا|Lithuania
LU|352|لوكسمبورغ|Luxembourg
MO|853|ماكاو|Macao
MG|261|مدغشقر|Madagascar
MW|265|مالاوي|Malawi
MY|60|ماليزيا|Malaysia
MV|960|جزر المالديف|Maldives
ML|223|مالي|Mali
MT|356|مالطا|Malta
MH|692|جزر مارشال|Marshall Islands
MQ|596|مارتينيك|Martinique
MR|222|موريتانيا|Mauritania
MU|230|موريشيوس|Mauritius
MX|52|المكسيك|Mexico
FM|691|ميكرونيزيا|Micronesia
MD|373|مولدوفا|Moldova
MC|377|موناكو|Monaco
MN|976|منغوليا|Mongolia
ME|382|الجبل الأسود|Montenegro
MS|1664|مونتسيرات|Montserrat
MA|212|المغرب|Morocco
MZ|258|موزمبيق|Mozambique
MM|95|ميانمار|Myanmar
NA|264|ناميبيا|Namibia
NR|674|ناورو|Nauru
NP|977|نيبال|Nepal
NL|31|هولندا|Netherlands
NC|687|كاليدونيا الجديدة|New Caledonia
NZ|64|نيوزيلندا|New Zealand
NI|505|نيكاراغوا|Nicaragua
NE|227|النيجر|Niger
NG|234|نيجيريا|Nigeria
KP|850|كوريا الشمالية|North Korea
MK|389|مقدونيا الشمالية|North Macedonia
NO|47|النرويج|Norway
OM|968|عُمان|Oman
PK|92|باكستان|Pakistan
PW|680|بالاو|Palau
PS|970|فلسطين|Palestine
PA|507|بنما|Panama
PG|675|بابوا غينيا الجديدة|Papua New Guinea
PY|595|باراغواي|Paraguay
PE|51|بيرو|Peru
PH|63|الفلبين|Philippines
PL|48|بولندا|Poland
PT|351|البرتغال|Portugal
PR|1787|بورتوريكو|Puerto Rico
QA|974|قطر|Qatar
RE|262|لا ريونيون|Réunion
RO|40|رومانيا|Romania
RU|7|روسيا|Russia
RW|250|رواندا|Rwanda
KN|1869|سانت كيتس ونيفيس|Saint Kitts and Nevis
LC|1758|سانت لوسيا|Saint Lucia
VC|1784|سانت فنسنت والغرينادين|Saint Vincent and the Grenadines
WS|685|ساموا|Samoa
SM|378|سان مارينو|San Marino
ST|239|ساو تومي وبرينسيبي|São Tomé and Príncipe
SN|221|السنغال|Senegal
RS|381|صربيا|Serbia
SC|248|سيشل|Seychelles
SL|232|سيراليون|Sierra Leone
SG|65|سنغافورة|Singapore
SX|1721|سانت مارتن|Sint Maarten
SK|421|سلوفاكيا|Slovakia
SI|386|سلوفينيا|Slovenia
SB|677|جزر سليمان|Solomon Islands
SO|252|الصومال|Somalia
ZA|27|جنوب أفريقيا|South Africa
KR|82|كوريا الجنوبية|South Korea
SS|211|جنوب السودان|South Sudan
ES|34|إسبانيا|Spain
LK|94|سريلانكا|Sri Lanka
SD|249|السودان|Sudan
SR|597|سورينام|Suriname
SE|46|السويد|Sweden
CH|41|سويسرا|Switzerland
SY|963|سوريا|Syria
TW|886|تايوان|Taiwan
TJ|992|طاجيكستان|Tajikistan
TZ|255|تنزانيا|Tanzania
TH|66|تايلاند|Thailand
TL|670|تيمور الشرقية|Timor-Leste
TG|228|توغو|Togo
TO|676|تونغا|Tonga
TT|1868|ترينيداد وتوباغو|Trinidad and Tobago
TN|216|تونس|Tunisia
TR|90|تركيا|Türkiye
TM|993|تركمانستان|Turkmenistan
TC|1649|جزر تركس وكايكوس|Turks and Caicos Islands
TV|688|توفالو|Tuvalu
UG|256|أوغندا|Uganda
UA|380|أوكرانيا|Ukraine
AE|971|الإمارات|United Arab Emirates
GB|44|المملكة المتحدة|United Kingdom
US|1|الولايات المتحدة|United States
UY|598|أوروغواي|Uruguay
UZ|998|أوزبكستان|Uzbekistan
VU|678|فانواتو|Vanuatu
VA|379|الفاتيكان|Vatican City
VE|58|فنزويلا|Venezuela
VN|84|فيتنام|Vietnam
YE|967|اليمن|Yemen
ZM|260|زامبيا|Zambia
ZW|263|زيمبابوي|Zimbabwe
"""
PINNED = """
JO|962|الأردن|Jordan
SA|966|السعودية|Saudi Arabia
EG|20|مصر|Egypt
"""

def rows(block):
    return [l.split("|") for l in block.strip().splitlines()]

def esc(s):
    return s.replace("\\", "\\\\").replace("'", "\\'")

def entry(r):
    c, d, ar, en = r
    return f"  Country(isoCode: '{c}', dialCode: '{d}', nameAr: '{esc(ar)}', nameEn: '{esc(en)}'),"

rest = sorted(rows(DATA), key=lambda r: r[3])
out = [
    "// GENERATED by tool/gen_countries.py — do not edit by hand.",
    "import 'country.dart';",
    "",
    "/// Every supported country. The first three (Jordan, Saudi Arabia, Egypt)",
    "/// are pinned on top; the rest are alphabetical by English name.",
    "const List<Country> kCountries = [",
    *[entry(r) for r in rows(PINNED)],
    *[entry(r) for r in rest],
    "];",
    "",
]
p = pathlib.Path(__file__).resolve().parent.parent / "lib/core/countries/countries_data.dart"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text("\n".join(out))
print(len(rows(PINNED)) + len(rest), "countries ->", p)
