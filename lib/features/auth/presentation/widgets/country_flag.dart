import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Round flag (20pt by default) like the dial-code block in the design.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.isoCode, this.size = 20});

  final String isoCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    final code = isoCode.toLowerCase();
    final dimension = size.r;
    return ClipOval(
      child: SizedBox.square(
        dimension: dimension,
        child: flagsCountryCodes.contains(code)
            ? SvgPicture.asset(
                'packages/country_flags/res/$code.svg',
                fit: BoxFit.cover,
              )
            : const ColoredBox(color: Color(0xFFEAECF0)),
      ),
    );
  }
}
