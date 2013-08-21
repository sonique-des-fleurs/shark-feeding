class WanderTarget {
  float radialPosition;
  PVector location;  
  float rateOfMotion;
  
  WanderTarget( PVector wanderTargetAreaLocation, float wandererOrientation, float wanderTargetAreaRadius ) {  
    radialPosition = wandererOrientation;
    location = new PVector( 0, 0 );
    location.x = wanderTargetAreaLocation.x + (cos( radialPosition ) * wanderTargetAreaRadius);
    location.y = wanderTargetAreaLocation.y + (sin( radialPosition ) * wanderTargetAreaRadius);
    rateOfMotion = 0.1;  
  }
  
  void process( PVector wanderTargetAreaLocation, float wanderTargetAreaRadius ) {
    float randomWalk = random( -1.0, 1.0 ) * rateOfMotion;
    radialPosition += randomWalk;
    
    if (radialPosition > PI) {
      radialPosition = -(TWO_PI - radialPosition);
    }
    else if (radialPosition < -PI) {
      radialPosition = TWO_PI - abs( radialPosition );
    }
    
    location.x = wanderTargetAreaLocation.x + (cos( radialPosition ) * wanderTargetAreaRadius);
    location.y = wanderTargetAreaLocation.y + (sin( radialPosition ) * wanderTargetAreaRadius);
  }
 
  void render() {
    stroke( 255, 255, 255 );
    strokeWeight( 1 );
    fill( 255 );
    pushMatrix();
    translate( location.x, location.y );
    ellipse( 0, 0, 2, 2 );
    popMatrix();
  }
}
