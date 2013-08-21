class Fish {
  color fishColor;  
  float mass;
  
  PVector location;
  float orientation;
  
  PVector velocity;
  float maxSpeed;
  
  PVector acceleration;
  float maxAcceleration;
  
  float maxTurnRate;
  
  Fish( float xLocation, float yLocation ) {
    location = new PVector( xLocation, yLocation );
    orientation = 0;
    
    velocity = new PVector( 0, 0 );
    
    acceleration = new PVector( 0, 0 );
    maxAcceleration = 0.1;
  }
  
  PVector seekToLocation( PVector seekLocation ) {
    PVector desiredVelocity = PVector.sub( seekLocation, location );
    desiredVelocity.normalize();
    float desiredHeading = desiredVelocity.heading();
    float headingDiff = desiredHeading - orientation;
    
    if (headingDiff > PI) {
      headingDiff = -(TWO_PI - headingDiff);
    }
    else if (headingDiff < -PI) {
      headingDiff = TWO_PI - abs( headingDiff );
    }

    float turnDelta = constrain( headingDiff, -maxTurnRate, maxTurnRate );
    float desiredOrientation = orientation + turnDelta;
    PVector seek = new PVector( cos( desiredOrientation ) * maxSpeed, sin( desiredOrientation ) * maxSpeed );
    
    return seek;
  }
  
  ArrayList findNearbyFish( ArrayList allFish, float maximumDistance, float maximumAngle ) {   
    ArrayList nearbyFish = new ArrayList();
    PVector orientationUnitVector = PVector.fromAngle( orientation );
    
    for (int i = 0; i < allFish.size(); i++) {
      Fish fish = (Fish)allFish.get(i);
      
      if (fish != this) {
        float distanceToFish = location.dist( fish.location );
        if (distanceToFish < maximumDistance) {
          PVector directionToFishUnitVector = PVector.sub( fish.location, location );
          directionToFishUnitVector.normalize();
          
          // taking the arccos of the dot product of the two vectors gives the angle (theta) between them, since
          // the dot product of two vectors A and B = ||A|| * ||B|| * cos(theta) = cos(theta) when A and B are unit vectors
          float angleToFish = acos(orientationUnitVector.dot( directionToFishUnitVector ));
                      
          if (angleToFish < maximumAngle) {
            nearbyFish.add( fish );
          }
        }
      }
    }
    return nearbyFish;
  }
  
  void wrap() {
    if (location.x > width)
      location.x = 0;
    else if (location.x < 0)
      location.x = width;
    if (location.y > height) 
      location.y = 0;
    else if (location.y < 0)
      location.y = height;
  }
}
