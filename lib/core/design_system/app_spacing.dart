import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double baseUnit = 4.0;
  static const double xs = baseUnit * 1;
  static const double sm = baseUnit * 2;
  static const double md = baseUnit * 3;
  static const double lg = baseUnit * 4;
  static const double xl = baseUnit * 5;
  static const double xxl = baseUnit * 6;
  static const double xxxl = baseUnit * 8;
  static const double huge = baseUnit * 12;
  static const double massive = baseUnit * 16;

  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  static const EdgeInsets paddingHorizontalXS =
      EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL =
      EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHorizontalXXL =
      EdgeInsets.symmetric(horizontal: xxl);

  static const EdgeInsets paddingVerticalXS =
      EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL =
      EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets paddingVerticalXXL =
      EdgeInsets.symmetric(vertical: xxl);

  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);
  static const EdgeInsets marginXXL = EdgeInsets.all(xxl);

  static const Widget gapXS = SizedBox(width: xs, height: xs);
  static const Widget gapSM = SizedBox(width: sm, height: sm);
  static const Widget gapMD = SizedBox(width: md, height: md);
  static const Widget gapLG = SizedBox(width: lg, height: lg);
  static const Widget gapXL = SizedBox(width: xl, height: xl);
  static const Widget gapXXL = SizedBox(width: xxl, height: xxl);
  static const Widget gapXXXL = SizedBox(width: xxxl, height: xxxl);

  static const Widget gapHorizontalXS = SizedBox(width: xs);
  static const Widget gapHorizontalSM = SizedBox(width: sm);
  static const Widget gapHorizontalMD = SizedBox(width: md);
  static const Widget gapHorizontalLG = SizedBox(width: lg);
  static const Widget gapHorizontalXL = SizedBox(width: xl);
  static const Widget gapHorizontalXXL = SizedBox(width: xxl);

  static const Widget gapVerticalXS = SizedBox(height: xs);
  static const Widget gapVerticalSM = SizedBox(height: sm);
  static const Widget gapVerticalMD = SizedBox(height: md);
  static const Widget gapVerticalLG = SizedBox(height: lg);
  static const Widget gapVerticalXL = SizedBox(height: xl);
  static const Widget gapVerticalXXL = SizedBox(height: xxl);
  static const Widget gapVerticalXXXL = SizedBox(height: xxxl);
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double circular = 999.0;

  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusXXXL =
      BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius radiusCircular =
      BorderRadius.all(Radius.circular(circular));

  static const BorderRadius radiusTopXS = BorderRadius.only(
    topLeft: Radius.circular(xs),
    topRight: Radius.circular(xs),
  );
  static const BorderRadius radiusTopSM = BorderRadius.only(
    topLeft: Radius.circular(sm),
    topRight: Radius.circular(sm),
  );
  static const BorderRadius radiusTopMD = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );
  static const BorderRadius radiusTopLG = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  static const BorderRadius radiusBottomXS = BorderRadius.only(
    bottomLeft: Radius.circular(xs),
    bottomRight: Radius.circular(xs),
  );
  static const BorderRadius radiusBottomSM = BorderRadius.only(
    bottomLeft: Radius.circular(sm),
    bottomRight: Radius.circular(sm),
  );
  static const BorderRadius radiusBottomMD = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );
  static const BorderRadius radiusBottomLG = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
}

class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double xs = 1.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
  static const double xxxl = 24.0;
}
