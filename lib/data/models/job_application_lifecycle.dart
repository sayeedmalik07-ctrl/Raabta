import 'package:raabta/data/models/job_application.dart';

abstract final class JobApplicationLifecycle {
  static bool canEmployerSet(
    JobApplicationStatus from,
    JobApplicationStatus to,
  ) {
    return switch (from) {
      JobApplicationStatus.applied => to == JobApplicationStatus.underReview ||
          to == JobApplicationStatus.contacted ||
          to == JobApplicationStatus.closed,
      JobApplicationStatus.underReview =>
        to == JobApplicationStatus.contacted ||
            to == JobApplicationStatus.closed,
      JobApplicationStatus.contacted => to == JobApplicationStatus.closed,
      JobApplicationStatus.closed => false,
    };
  }

  static String forwardStorageValue(JobApplicationStatus status) =>
      status.storageValue;
}
