/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.firebase.geofire;

import androidx.annotation.NonNull;

import com.firebase.geofire.core.GeoHash;
import com.firebase.geofire.core.GeoHashQuery;
import com.firebase.geofire.util.GeoUtils;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import static com.firebase.geofire.util.GeoUtils.capRadius;

/**
 * A GeoQuery object can be used for geo queries in a given circle. The GeoQuery class is thread safe.
 */
public class GeoQuery {
    private static final int KILOMETER_TO_METER = 1000;

    private static class LocationInfo {
        final GeoLocation location;
        final boolean inGeoQuery;
        final GeoHash geoHash;
        final DataSnapshot dataSnapshot;

        public LocationInfo(GeoLocation location, boolean inGeoQuery, DataSnapshot dataSnapshot) {
            this.location = location;
            this.inGeoQuery = inGeoQuery;
            this.geoHash = new GeoHash(location);
            this.dataSnapshot = dataSnapshot;
        }
    }

    private final ChildEventListener childEventLister = new ChildEventListener() {
        @Override
        public void onChildAdded(@NonNull DataSnapshot dataSnapshot, String s) {
            synchronized (GeoQuery.this) {
                GeoQuery.this.childAdded(dataSnapshot);
            }
        }

        @Override
        public void onChildChanged(@NonNull DataSnapshot dataSnapshot, String s) {
            synchronized (GeoQuery.this) {
                GeoQuery.this.childChanged(dataSnapshot);
            }
        }

        @Override
        public void onChildRemoved(@NonNull DataSnapshot dataSnapshot) {
            synchronized (GeoQuery.this) {
                GeoQuery.this.childRemoved(dataSnapshot);
            }
        }

        @Override
        public synchronized void onChildMoved(@NonNull DataSnapshot dataSnapshot, String s) {
            // ignore, this should be handled by onChildChanged
        }

        @Override
        public synchronized void onCancelled(@NonNull DatabaseError databaseError) {
            // ignore, our API does not support onCancelled
        }
    };

    private final GeoFire geoFire;
    private final Set<GeoQueryDataEventListener> eventListeners = new HashSet<>();
    private final Map<GeoHashQuery, Query> firebaseQueries = new HashMap<>();
    private final Set<GeoHashQuery> outstandingQueries = new HashSet<>();
    private final Map<String, LocationInfo> locationInfos = new HashMap<>();
    private GeoLocation center;
    private double radius;
    private Set<GeoHashQuery> queries;

    /**
     * Creates a new GeoQuery object centered at the given location and with the given radius.
     *
     * @param geoFire The GeoFire object this GeoQuery uses
     * @param center  The center of this query
     * @param radius  The radius of the query, in kilometers. The maximum radius that is
     *                supported is about 8587km. If a radius bigger than this is passed we'll cap it.
     */
    GeoQuery(GeoFire geoFire, GeoLocation center, double radius) {
        this.geoFire = geoFire;
        this.center = center;
        this.radius = radius * KILOMETER_TO_METER; // Convert from kilometers to meters.
    }

    private boolean locationIsInQuery(GeoLocation location) {
        return GeoUtils.distance(location, center) <= this.radius;
    }

    private void updateLocationInfo(final DataSnapshot dataSnapshot, final GeoLocation location) {
        String key = dataSnapshot.getKey();
        LocationInfo oldInfo = this.locationInfos.get(key);
        boolean isNew = oldInfo == null;
        final boolean changedLocation = oldInfo != null && !oldInfo.location.equals(location);
        boolean wasInQuery = oldInfo != null && oldInfo.inGeoQuery;

        boolean isInQuery = this.locationIsInQuery(location);
        if ((isNew || !wasInQuery) && isInQuery) {
            for (final GeoQueryDataEventListener listener : this.eventListeners) {
                this.geoFire.raiseEvent(new Runnable() {
                    @Override
                    public void run() {
                        listener.onDataEntered(dataSnapshot, location);
                    }
                });
            }
        } else if (!isNew && isInQuery) {
            for (final GeoQueryDataEventListener listener : this.eventListeners) {
                this.geoFire.raiseEvent(new Runnable() {
                    @Override
                    public void run() {
                        if (changedLocation) {
                            listener.onDataMoved(dataSnapshot, location);
                        } else {
                            listener.onDataChanged(dataSnapshot, location);
                        }
                    }
                });
            }
        } else if (wasInQuery && !isInQuery) {
            for (final GeoQueryDataEventListener listener : this.eventListeners) {
                this.geoFire.raiseEvent(new Runnable() {
                    @Override
                    public void run() {
                        listener.onDataExited(dataSnapshot);
                    }
                });
            }
        }
        LocationInfo newInfo = new LocationInfo(location, this.locationIsInQuery(location), dataSnapshot);
        this.locationInfos.put(key, newInfo);
    }

    private boolean geoHashQueriesContainGeoHash(GeoHash geoHash) {
        if (this.queries == null) {
            return false;
        }
        for (GeoHashQuery query : this.queries) {
            if (query.containsGeoHash(geoHash)) {
                return true;
            }
        }
        return false;
    }

    private void reset() {
        for (Map.Entry<GeoHashQuery, Query> entry : this.firebaseQueries.entrySet()) {
            entry.getValue().removeEventListener(this.childEventLister);
        }
        this.outstandingQueries.clear();
        this.firebaseQueries.clear();
        this.queries = null;
        this.locationInfos.clear();
    }

    private boolean hasListeners() {
        return !this.eventListeners.isEmpty();
    }

    private boolean canFireReady() {
        return this.outstandingQueries.isEmpty();
    }

    private void checkAndFireReady() {
        if (canFireReady()) {
            for (final GeoQueryDataEventListener listener : this.eventListeners) {
                this.geoFire.raiseEvent(new Runnable() {
                    @Override
                    public void run() {
                        listener.onGeoQueryReady();
                    }
                });
            }
        }
    }

    private void addValueToReadyListener(final Query firebase, final GeoHashQuery query) {
        firebase.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                synchronized (GeoQuery.this) {
                    GeoQuery.this.outstandingQueries.remove(query);
                    GeoQuery.this.checkAndFireReady();
                }
            }

            @Override
            public void onCancelled(@NonNull final DatabaseError databaseError) {
                synchronized (GeoQuery.this) {
                    for (final GeoQueryDataEventListener listener : GeoQuery.this.eventListeners) {
                        GeoQuery.this.geoFire.raiseEvent(new Runnable() {
                            @Override
                            public void run() {
                                listener.onGeoQueryError(databaseError);
                            }
                        });
                    }
                }
            }
        });
    }

    private void setupQueries() {
        Set<GeoHashQuery> oldQueries = (this.queries == null) ? new HashSet<GeoHashQuery>() : this.queries;
        Set<GeoHashQuery> newQueries = GeoHashQuery.queriesAtLocation(center, radius);
        this.queries = newQueries;
        for (GeoHashQuery query : oldQueries) {
            if (!newQueries.contains(query)) {
                firebaseQueries.get(query).removeEventListener(this.childEventLister);
                firebaseQueries.remove(query);
                outstandingQueries.remove(query);
            }
        }
        for (final GeoHashQuery query : newQueries) {
            if (!oldQueries.contains(query)) {
                outstandingQueries.add(query);
                DatabaseReference databaseReference = this.geoFire.getDatabaseReference();
                Query firebaseQuery = databaseReference.orderByChild("g").startAt(query.getStartValue()).endAt(query.getEndValue());
                firebaseQuery.addChildEventListener(this.childEventLister);
                addValueToReadyListener(firebaseQuery, query);
                firebaseQueries.put(query, firebaseQuery);
            }
        }
        for (Map.Entry<String, LocationInfo> info : this.locationInfos.entrySet()) {
            LocationInfo oldLocationInfo = info.getValue();

            if (oldLocationInfo != null) {
                updateLocationInfo(oldLocationInfo.dataSnapshot, oldLocationInfo.location);
            }
        }
        // remove locations that are not part of the geo query anymore
        Iterator<Map.Entry<String, LocationInfo>> it = this.locationInfos.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, LocationInfo> entry = it.next();
            if (!this.geoHashQueriesContainGeoHash(entry.getValue().geoHash)) {
                it.remove();
            }
        }

        checkAndFireReady();
    }

    private void childAdded(DataSnapshot dataSnapshot) {
        boolean errorOccured = false;
        String errMsg = "";
        try {
            GeoLocation location = GeoFire.getLocationValue(dataSnapshot);
            if (location != null) {
                this.updateLocationInfo(dataSnapshot, location);
            } else {
                errorOccured = true;
            }
        } catch (Exception e) {
            errorOccured = true;
            errMsg = e.getMessage();
        } finally {
            if (errorOccured) {
                // TODO: do not throw exception just b/c the node doesn't have a valid location. maybe have a (dev | prod) version so the dev can crash and we can see what is happening
                //throw new AssertionError("childAdded: Got Datasnapshot without location with key " + dataSnapshot.getKey() + " with error " + errMsg);
            }
        }
    }

    private void childChanged(DataSnapshot dataSnapshot) {
        boolean errorOccured = false;
        String errMsg = "";
        try {
            GeoLocation location = GeoFire.getLocationValue(dataSnapshot);
            if (location != null) {
                this.updateLocationInfo(dataSnapshot, location);
            } else {
                errorOccured = true;
            }
        } catch (Exception e) {
            errorOccured = true;
            errMsg = e.getMessage();
        } finally {
            if (errorOccured) {
                // TODO: do not throw exception just b/c the node doesn't have a valid location. maybe have a (dev | prod) version so the dev can crash and we can see what is happening
                //throw new AssertionError("childChanged: Got Datasnapshot without location with key " + dataSnapshot.getKey() + " with error " + errMsg);
            }
        }
    }

    private void childRemoved(DataSnapshot dataSnapshot) {
        final String key = dataSnapshot.getKey();
        final LocationInfo info = this.locationInfos.get(key);
        if (info != null) {
            this.geoFire.getDatabaseRefForKey(key).addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull final DataSnapshot dataSnapshot) {
                    synchronized (GeoQuery.this) {
                        GeoLocation location;
                        try {
                            location = GeoFire.getLocationValue(dataSnapshot);
                        } catch (Exception e) {
                            location = null;
                        }
                        GeoHash hash = (location != null) ? new GeoHash(location) : null;
                        if (hash == null || !GeoQuery.this.geoHashQueriesContainGeoHash(hash)) {
                            final LocationInfo info = locationInfos.remove(key);

                            if (info != null && info.inGeoQuery) {
                                for (final GeoQueryDataEventListener listener : GeoQuery.this.eventListeners) {
                                    GeoQuery.this.geoFire.raiseEvent(new Runnable() {
                                        @Override
                                        public void run() {
                                            listener.onDataExited(info.dataSnapshot);
                                        }
                                    });
                                }
                            }
                        }
                    }
                }

                @Override
                public void onCancelled(@NonNull DatabaseError databaseError) {
                    // tough luck
                }
            });
        }
    }

    /**
     * Adds a new GeoQueryEventListener to this GeoQuery.
     *
     * @param listener The listener to add
     * @throws IllegalArgumentException If this listener was already added
     */
    public synchronized void addGeoQueryEventListener(final GeoQueryEventListener listener) {
        addGeoQueryDataEventListener(new EventListenerBridge(listener));
    }

    /**
     * Adds a new GeoQueryEventListener to this GeoQuery.
     *
     * @param listener The listener to add
     * @throws IllegalArgumentException If this listener was already added
     */
    public synchronized void addGeoQueryDataEventListener(final GeoQueryDataEventListener listener) {
        if (eventListeners.contains(listener)) {
            throw new IllegalArgumentException("Added the same listener twice to a GeoQuery!");
        }
        eventListeners.add(listener);
        if (this.queries == null) {
            this.setupQueries();
        } else {
            for (final Map.Entry<String, LocationInfo> entry : this.locationInfos.entrySet()) {
                final String key = entry.getKey();
                final LocationInfo info = entry.getValue();

                if (info.inGeoQuery) {
                    this.geoFire.raiseEvent(new Runnable() {
                        @Override
                        public void run() {
                            listener.onDataEntered(info.dataSnapshot, info.location);
                        }
                    });
                }
            }
            if (this.canFireReady()) {
                this.geoFire.raiseEvent(new Runnable() {
                    @Override
                    public void run() {
                        listener.onGeoQueryReady();
                    }
                });
            }
        }
    }

    /**
     * Removes an event listener.
     *
     * @param listener The listener to remove
     * @throws IllegalArgumentException If the listener was removed already or never added
     */
    public synchronized void removeGeoQueryEventListener(GeoQueryEventListener listener) {
        removeGeoQueryEventListener(new EventListenerBridge(listener));
    }

    /**
     * Removes an event listener.
     *
     * @param listener The listener to remove
     * @throws IllegalArgumentException If the listener was removed already or never added
     */
    public synchronized void removeGeoQueryEventListener(final GeoQueryDataEventListener listener) {
        if (!eventListeners.contains(listener)) {
            throw new IllegalArgumentException("Trying to remove listener that was removed or not added!");
        }
        eventListeners.remove(listener);
        if (!this.hasListeners()) {
            reset();
        }
    }

    /**
     * Removes all event listeners from this GeoQuery.
     */
    public synchronized void removeAllListeners() {
        eventListeners.clear();
        reset();
    }

    /**
     * Returns the current center of this query.
     *
     * @return The current center
     */
    public synchronized GeoLocation getCenter() {
        return center;
    }

    /**
     * Sets the new center of this query and triggers new events if necessary.
     *
     * @param center The new center
     */
    public synchronized void setCenter(GeoLocation center) {
        this.center = center;
        if (this.hasListeners()) {
            this.setupQueries();
        }
    }

    /**
     * Returns the radius of the query, in kilometers.
     *
     * @return The radius of this query, in kilometers
     */
    public synchronized double getRadius() {
        // convert from meters
        return radius / KILOMETER_TO_METER;
    }

    /**
     * Sets the radius of this query, in kilometers, and triggers new events if necessary.
     *
     * @param radius The radius of the query, in kilometers. The maximum radius that is
     *               supported is about 8587km. If a radius bigger than this is passed we'll cap it.
     */
    public synchronized void setRadius(double radius) {
        // convert to meters
        this.radius = capRadius(radius) * KILOMETER_TO_METER;
        if (this.hasListeners()) {
            this.setupQueries();
        }
    }

    /**
     * Sets the center and radius (in kilometers) of this query, and triggers new events if necessary.
     *
     * @param center The new center
     * @param radius The radius of the query, in kilometers. The maximum radius that is
     *               supported is about 8587km. If a radius bigger than this is passed we'll cap it.
     */
    public synchronized void setLocation(GeoLocation center, double radius) {
        this.center = center;
        // convert radius to meters
        this.radius = capRadius(radius) * KILOMETER_TO_METER;
        if (this.hasListeners()) {
            this.setupQueries();
        }
    }
}
