class WanderTargetArea {
  PVector location;
  float distanceAheadOfWanderer;
  float radiusOfTargetArea;
  
  WanderTarget wanderTarget;
  
  WanderTargetArea( PVector wandererLocation, float wandererOrientation, float wandererLookAhead ) {
    distanceAheadOfWanderer = wandererLookAhead;
    
    PVector forwardOffset = new PVector( cos( wandererOrientation ) * distanceAheadOfWanderer, sin( wandererOrientation ) * distanceAheadOfWanderer);
    location = new PVector( 0, 0 );
    location.x = wandererLocation.x + forwardOffset.x;
    location.y = wandererLocation.y + forwardOffset.y;
    
    radiusOfTargetArea = 16.0;
    
    wanderTarget = new WanderTarget( location, wandererOrientation, radiusOfTargetArea );
  }
  
  void process( PVector wandererLocation, float wandererOrientation ) {
    PVector forwardOffset = new PVector( cos( wandererOrientation) * distanceAheadOfWanderer, sin( wandererOrientation ) * distanceAheadOfWanderer);
    
    location = new PVector( 0, 0);
    location.x = wandererLocation.x + forwardOffset.x;
    location.y = wandererLocation.y + forwardOffset.y;
    
    wanderTarget.process ( location, radiusOfTargetArea );
  }
  
  PVector targetLocation() {
    return wanderTarget.location;
  }
  
  void render() {
    stroke( 0, 0, 255 );
    strokeWeight( 2 );
    noFill();
    pushMatrix();
    translate( location.x, location.y );
    ellipse( 0, 0, radiusOfTargetArea * 2, radiusOfTargetArea * 2 );
    popMatrix();
    wanderTarget.render();
  }
}
