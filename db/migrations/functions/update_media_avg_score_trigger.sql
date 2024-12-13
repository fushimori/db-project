-- db/migrations/functions/update_media_avg_score_trigger.sql
CREATE OR REPLACE FUNCTION update_media_avg_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE MediaContent
    SET avg_rating = (
        SELECT AVG(score) FROM Ratings WHERE media_id = NEW.media_id
    )
    WHERE id = NEW.media_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_avg_rating_trigger
AFTER INSERT OR UPDATE OR DELETE ON Ratings
FOR EACH ROW
EXECUTE FUNCTION update_media_avg_rating();
