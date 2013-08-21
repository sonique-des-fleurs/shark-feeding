class Shark extends Fish { 
  float maxAttackSpeed;
  float maxCoastingSpeed;

  PVector portTailVertex;
  PVector starboardTailVertex;
  PVector headVertex;

  String actionState;

  float wanderLookAhead;
  WanderTargetArea wanderTargetArea;

  String tailWagDirection;

  float attackRange;
  float maximumAttackAngle;
  PVector attackLocation;

  int coastingTimer;
  int coastingTimeLimit;

  int attackTimer;
  int attackTimeLimit;

  Shark( float xLocation, float yLocation ) {
    super( xLocation, yLocation );

    fishColor = color( 255, 0, 0 );
    mass = 4.0;

    maxSpeed = 2.0;  // 3.0?
    maxAttackSpeed = 4.0;
    maxCoastingSpeed = 1.5;

    maxTurnRate = PI;

    // initialize shark-specific attributes
    portTailVertex = new PVector(-6, -6);
    starboardTailVertex = new PVector(-6, 6);
    headVertex = new PVector(6, 0);

    portTailVertex.mult(mass);
    starboardTailVertex.mult(mass);
    headVertex.mult(mass);

    actionState = "wander";

    wanderLookAhead = 64.0;
    wanderTargetArea = new WanderTargetArea( location, orientation, wanderLookAhead );

    tailWagDirection = "left";

    attackRange = 360.0;
    maximumAttackAngle = PI / 6;
    attackLocation = new PVector(-1000, -1000);

    coastingTimer = 0;
    coastingTimeLimit = 100;

    attackTimer = 0;
    attackTimeLimit = 180;
  }

  void checkState() {
    if (actionState == "wander") {      
      ArrayList nearbyTuna = findNearbyFish( allTuna, attackRange, maximumAttackAngle );

      if ( nearbyTuna.size() > smallestMealSize ) {
        PVector sumOfNearbyTunaLocationVectors = new PVector( 0, 0 );
        for (int i = 0; i < nearbyTuna.size(); i++) {
          Tuna tuna = (Tuna)nearbyTuna.get(i);
          sumOfNearbyTunaLocationVectors.add( tuna.location );
        }
        sumOfNearbyTunaLocationVectors.div( nearbyTuna.size() );
        attackLocation = sumOfNearbyTunaLocationVectors;
        PVector attackLocationOvershoot = PVector.sub( attackLocation, location );
        attackLocationOvershoot.div(2);
        attackLocation.add( attackLocationOvershoot );
        actionState = "attack";
      }
    }
    else if (actionState == "attack") {
      if ((location.dist(attackLocation) < 20) || (attackTimer > attackTimeLimit)) {
        actionState = "rest";
        attackLocation = new PVector(-1000, -1000);
        attackTimer = 0;
      }
    }
    else if (actionState == "rest") {
      if (coastingTimer > coastingTimeLimit) {
        actionState = "wander";
        coastingTimer = 0;
      }
    }
  }

  void process() {
    if (actionState == "wander") {
      PVector wanderTargetLocation = wanderTargetArea.targetLocation();
      PVector wanderAcceleration = seekToLocation( wanderTargetLocation );
      acceleration.add( wanderAcceleration );

      acceleration.div( mass );
      acceleration.limit( maxAcceleration );

      velocity.add( acceleration );
      velocity.limit( maxSpeed );

      if (velocity.mag() > 0.01) {
        orientation = velocity.heading2D();
      }

      location.add( velocity );
      wrap();

      acceleration.x = 0;
      acceleration.y = 0;

      wanderTargetArea.process( location, orientation );
    }
    else if (actionState == "attack") {
      PVector attackAcceleration = seekToLocation( attackLocation );
      acceleration.add( attackAcceleration );

      acceleration.div( mass );
      acceleration.limit( maxAcceleration );

      velocity.add( acceleration );
      velocity.limit( maxAttackSpeed );

      if (velocity.mag() > 0.01) {
        orientation = velocity.heading2D();
      }

      location.add( velocity );
      wrap();

      acceleration.x = 0;
      acceleration.y = 0;

      attackTimer++;

      wanderTargetArea.process( location, orientation );
    }
    else if (actionState == "rest") {
      velocity.limit( maxCoastingSpeed );
      location.add( velocity );
      wrap();

      acceleration.x = 0;
      acceleration.y = 0;

      coastingTimer++;

      wanderTargetArea.process( location, orientation );
    }
  }

  void render() {
    if (actionState == "wander") {
      if (tailWagDirection == "left") {
        portTailVertex.y = portTailVertex.y - 1.5;
        starboardTailVertex.y = starboardTailVertex.y - 1.5;

        if (portTailVertex.y < (-6 * mass)) {
          portTailVertex.y = (-6 * mass);
        }
        if (starboardTailVertex.y < (3 * mass)) {
          tailWagDirection = "right";
        }
      }
      else {
        portTailVertex.y = portTailVertex.y + 1.5;
        starboardTailVertex.y = starboardTailVertex.y + 1.5;

        if (starboardTailVertex.y > (6 * mass)) {
          starboardTailVertex.y = (6 * mass);
        }
        if (portTailVertex.y > (-3 * mass)) {
          tailWagDirection = "left";
        }
      }
    }
    else if (actionState == "attack") {
      portTailVertex.y = (-3 * mass);
      starboardTailVertex.y = (3 * mass);
    }
    else if (actionState == "rest") {
      portTailVertex.y = (-5 * mass);
      starboardTailVertex.y = (5 * mass);
    }

    pushMatrix();
    translate( location.x, location.y );
    rotate( orientation );
    stroke( fishColor );
    strokeWeight( 2 );
    fill( 0 );
    triangle( portTailVertex.x, portTailVertex.y, starboardTailVertex.x, starboardTailVertex.y, headVertex.x, headVertex.y );
    popMatrix();
    
    // uncomment the below in order to see the shark's wanderTargetArea
    // wanderTargetArea.render();
  }
}

