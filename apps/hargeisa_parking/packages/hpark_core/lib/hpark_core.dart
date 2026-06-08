/// Hargeisa Parking shared core — design system, models, and data repositories
/// used by HPark Enforce (officers), HPark Pay (citizens) and HPark Command (admin).
library;

// Theme / design tokens
export 'src/theme/hp_colors.dart';
export 'src/theme/hp_spacing.dart';
export 'src/theme/hp_typography.dart';
export 'src/theme/hp_theme.dart';

// Models
export 'src/models/approval_status.dart';
export 'src/models/officer.dart';
export 'src/models/district.dart';
export 'src/models/vehicle.dart';
export 'src/models/violation.dart';
export 'src/models/appeal.dart';

// Data
export 'src/data/districts.dart';
export 'src/data/officer_repository.dart';
export 'src/data/enforcement_data.dart';
export 'src/data/auth_service.dart';

// Widgets
export 'src/widgets/hp_card.dart';
export 'src/widgets/hp_button.dart';
export 'src/widgets/hp_badge.dart';
export 'src/widgets/hp_avatar.dart';
export 'src/widgets/hp_kpi_card.dart';
export 'src/widgets/hp_logo.dart';
export 'src/widgets/hp_input.dart';
