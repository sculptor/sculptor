package org.sculptor.examples.library.media.repositoryimpl;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.PhysicalMedia;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for PhysicalMedia
 */
@Repository("physicalMediaRepository")
public class PhysicalMediaRepositoryImpl extends PhysicalMediaRepositoryBase {
    public PhysicalMediaRepositoryImpl() {
    }

    @Override
    public PhysicalMedia save(PhysicalMedia entity) {
        // bidirectional association is complicated, because one end must be
        // saved first.
        // We could maybe simplify it to allow assignment of id before object is
        // saved (it is possible with mongoDB).
        if (entity.getId() == null && entity.isMediaLoaded()) {
            List<Media> media = new ArrayList<Media>(entity.getMedia());
            entity.removeAllMedia();
            PhysicalMedia saved = super.save(entity);
            for (Media each : media) {
                saved.addMedia(each);
                getMediaRepository().save(each);
            }
            return super.save(entity);
        } else {
            if (entity.isMediaLoaded()) {
                for (Media each : entity.getMedia()) {
                    getMediaRepository().save(each);
                }
            }

            return super.save(entity);
        }
    }
}
