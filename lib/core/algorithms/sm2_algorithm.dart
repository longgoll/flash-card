import '../../data/models/card_model.dart';

class SpacedRepetition {
  // Ratings:
  // 0: Forgotten (Quên) -> Reset
  // 1: Hard (Khó) -> Vẫn nhớ nhưng sai lần đầu (trong session) hoặc chật vật
  // 2: Good (Được) -> Nhớ, hơi ngập ngừng
  // 3: Easy (Dễ) -> Nhớ ngay lập tức

  static CardModel calculate(CardModel card, int rating) {
    int newStreak = card.streak;
    double newEase = card.easeFactor;
    int newInterval = card.interval;

    if (rating == 0) {
      // Forgot
      newStreak = 0;
      newInterval = 0; // Review next session/day
      // Ease penalty
      newEase -= 0.2;
    } else {
      // Remembered (Rating 1, 2, 3)

      // Update Interval
      if (newStreak == 0) {
        newInterval = 1;
      } else if (newStreak == 1) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEase).round();
      }

      // Update Streak
      newStreak++;

      // Update Ease Factor (Standard SM-2 formula)
      // EF' = EF + (0.1 - (5-q)*(0.08+(5-q)*0.02))
      // Mapped our 0-3 rating to SM-2's 0-5 scale roughly:
      // Our 0 -> SM 0
      // Our 1 -> SM 3
      // Our 2 -> SM 4
      // Our 3 -> SM 5

      int sm2Rating = 0;
      if (rating == 1) sm2Rating = 3;
      if (rating == 2) sm2Rating = 4;
      if (rating == 3) sm2Rating = 5;

      newEase =
          newEase + (0.1 - (5 - sm2Rating) * (0.08 + (5 - sm2Rating) * 0.02));
    }

    // Constraints
    if (newEase < 1.3) newEase = 1.3;
    if (newEase > 2.5) newEase = 2.5; // Optional cap to prevent overflow

    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    return card.copyWith(
      streak: newStreak,
      easeFactor: newEase,
      interval: newInterval,
      nextReview: nextReviewDate,
      reviewCount: card.reviewCount + 1,
      lapses: rating == 0 ? card.lapses + 1 : card.lapses,
    );
  }
}
