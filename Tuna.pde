class Tuna extends Fish {  
  boolean isFlocking;
  
  float flockDistance;
  float flockAngle;
  
  float cohesionWeight;
  float separationWeight;
  float alignmentWeight;

  float avoidSharkRange;
  

  float closestDistance;
  PVector closestIntersect; 
  
  
  int flockInfluence; 
  
  boolean isAlive;

  Tuna( float xLocation, float yLocation ) {
    super( xLocation, yLocation );
    
    fishColor = color( 222, 222, 222 );
    mass = 1.0;
   
    maxSpeed = 1.5 + random(-0.15, 0.15);
    
    maxTurnRate = TWO_PI / 10.0;
        
    // initialize tuna-specific attributes
    isFlocking = true;
    
    flockDistance = 60.0 + random(-3.0, 3.0);
    flockAngle = PI + random(-1 * PI/16, PI/16);
    
    cohesionWeight = 0.35 + random(-0.05, 0.05);
    separationWeight = 0.25 + random(-0.05, 0.05);
    alignmentWeight = 0.25 + random(-0.05, 0.05);
    
    avoidSharkRange = 150.0;
    // closestDistance ??
    // closestIntersect ??
      
    flockInfluence = 0;

    isAlive = true;
  }

  void process() {
    for (int i = 0; i < numberOfSharks; i++) {
      Shark shark = (Shark)allSharks.get(i);
      if (location.dist(shark.location) < 24) {
        isAlive = false;
      }
    }
    
    PVector avoidSharkForce = avoidSharks();
    acceleration.add( avoidSharkForce );

    if (avoidSharkForce.mag() < 0.01) {
      if (isFlocking) {
        ArrayList neighbors = findNearbyFish( allTuna, flockDistance, flockAngle );
        flockInfluence += neighbors.size();
          
        PVector cohesionForce = cohesion( neighbors );
        cohesionForce.normalize(); 
        cohesionForce.mult( cohesionWeight );
        acceleration.add( cohesionForce );
        
        PVector separationForce = separation( neighbors );
        separationForce.normalize();    
        separationForce.mult( separationWeight );
        acceleration.add( separationForce );
              
        PVector alignmentForce = alignment( neighbors );
        alignmentForce.normalize();
        alignmentForce.mult( alignmentWeight );
        acceleration.add( alignmentForce );
      }
    }
    
    acceleration.div( mass );
    acceleration.limit( maxAcceleration );

    velocity.add( acceleration );
    velocity.limit( maxSpeed );

    if (velocity.mag() > 0.01) {
      orientation = velocity.heading();
    }

    location.add( velocity );
    wrap();

    acceleration.x = 0;
    acceleration.y = 0;
  
  }

  PVector cohesion( ArrayList neighbors ) {
    PVector steer = new PVector( 0, 0 );
    
    if (neighbors.size() == 0) {
      return steer;
    }
      
    PVector sumOfPositions = new PVector( 0, 0 );
    for (int i = 0; i < neighbors.size(); i++) {
      Tuna tuna = (Tuna)neighbors.get(i);
      sumOfPositions.add( tuna.location );
    }
    
    sumOfPositions.div( neighbors.size() );
    PVector averagePosition = sumOfPositions;
    steer = seekToLocation( averagePosition );
    return steer;
  }
  
  PVector separation( ArrayList neighbors ) {
    PVector steer = new PVector( 0, 0 );
    
    if (neighbors.size() == 0) {
      return steer;
    } 
    
    for (int i = 0; i < neighbors.size(); i++) {
      Tuna tuna = (Tuna)neighbors.get(i);
      PVector separationVector = PVector.sub( location, tuna.location );
      float separationDistance = separationVector.mag();
      separationVector.normalize();
      separationVector.mult( 1.0 / (separationDistance * separationDistance) );
      steer.add( separationVector );
    }
    
    return steer;
  }
  
  PVector alignment( ArrayList neighbors ) {
    PVector steer = new PVector( 0, 0 );
    
    if (neighbors.size() == 0) {
      return steer;
    }
    
    for (int i = 0; i < neighbors.size(); i++) {
      Tuna tuna = (Tuna)neighbors.get(i);
      PVector directionOfNeighbor = tuna.velocity.get();
      float distanceToNeighbor = location.dist( tuna.location );
      float alignmentStrength = map( distanceToNeighbor, 0, flockDistance, 1.0, 0.0 );
      directionOfNeighbor.mult( alignmentStrength );
      steer.add( directionOfNeighbor );
    }
    steer.div( neighbors.size() );
    
    return steer;
  }
  
  PVector avoidSharks() {
    PVector steer = new PVector( 0, 0 );
    PVector directionOfTravel = velocity.get(); 
    directionOfTravel.normalize();
    directionOfTravel.mult( avoidSharkRange );
    
    closestDistance = Float.MAX_VALUE;
    closestIntersect = new PVector( 0, 0 );

    for (int i = 0; i < numberOfSharks; i++) {
      Shark shark = (Shark)allSharks.get(i);
      float distanceToShark = location.dist( shark.location );
      
      if (distanceToShark < avoidSharkRange) {
        if (shouldAvoidShark( shark, directionOfTravel )) {
          PVector velocityUnitVector = velocity.get();
          velocityUnitVector.normalize();
          steer = new PVector( -velocityUnitVector.y, velocityUnitVector.x );
          PVector sharkDirection = PVector.sub( shark.location, location );
          float w = sharkDirection.dot( steer );
          if (w > 0) {
            steer.mult( -1.0 );
          }
          float avoidanceIntensity = map( distanceToShark, 0, avoidSharkRange, maxSpeed, 0 );
          steer.mult( avoidanceIntensity );
        }
      }
    }

    return steer;
  }

  boolean shouldAvoidShark( Shark shark, PVector direction ) {
    PVector a0 = new PVector( location.x - shark.location.x, location.y - shark.location.y );
    PVector b0 = new PVector( location.x + direction.x - shark.location.x, location.y + direction.y - shark.location.y );
    float dx = b0.x - a0.x;
    float dy = b0.y - a0.y;
    float dr = sqrt( dx * dx + dy * dy );
    float d  = a0.x * b0.y - b0.x * a0.y;
    float discrim = ((100) * (100) * dr * dr) - (d * d);
    if (discrim > 0) {
      float sqrt_discrim = sqrt( discrim );
      float x1 = (d * dy + signOf(dy) * dx * sqrt_discrim) / (dr * dr);
      float y1 = (-d * dx + abs(dy) * sqrt_discrim) / (dr * dr);
      PVector p1 = new PVector( x1, y1 );
      float x2 = (d * dy - signOf(dy) * dx * sqrt_discrim) / (dr * dr);
      float y2 = (-d * dx - abs(dy) * sqrt_discrim) / (dr * dr);
      PVector p2 = new PVector( x2, y2 );
      float distance_p1 = a0.dist( p1 );
      float distance_p2 = a0.dist( p2 );
      float distance = min( distance_p1, distance_p2 );

      if (distance < closestDistance) {
        closestDistance = distance;
        if (distance_p1 < distance_p2) {
          closestIntersect.x = shark.location.x + x1;
          closestIntersect.y = shark.location.y + y1;
        }
        else {
          closestIntersect.x = shark.location.x + x2;
          closestIntersect.y = shark.location.y + y2;
        }
        return true;
      }
    }
    return false;
  }

  float signOf( float x ) {
    if (x < 0)
      return -1.0;
    else
      return 1.0;
  }

  void render() {
    pushMatrix();
    translate( location.x, location.y );
    rotate( orientation );
    float influencedStrokeWeight = map(flockInfluence, 0, numberOfTuna / 8, 0, 3);
    float influencedColor = map(flockInfluence, 0, numberOfTuna / 8, 128, 255);
    strokeWeight( influencedStrokeWeight );
    stroke( influencedColor );
    fill ( influencedColor );
    triangle( -6 * mass, -5 * mass, -6 * mass, 5 * mass, 6 * mass, 0 );
    popMatrix();
  }
}

