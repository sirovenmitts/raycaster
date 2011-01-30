// A raycaster
// Check out these resources for more information:
// http://www.student.kuleuven.be/~m0216922/CG/raycasting.html
// http://www.permadi.com/tutorial/raycast/index.html
int world[][] = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}};
PVector position, direction, plane;
float moveSpeed, rotSpeed, mouseSensitivity;
boolean keyMap[];
int center, currentBuffer;
void setup() {
  size(300, 300 );
  position = new PVector(22, 20);
  direction = new PVector(-1, 0);
  plane = new PVector(0, 0.66);
  moveSpeed = 0.075;
  rotSpeed = 0.1;
  mouseSensitivity = 1; // only values between 0 and 1 please!
  keyMap = new boolean[6];
  for(int i = 0; i < keyMap.length; i++)
    keyMap[i] = false;
  center = height / 2;
}
void draw() {
  loadPixels();
  for(int x = 0; x < width; x++) {
    float cameraX = 2.0 * x / width - 1;
    PVector rayPosition = new PVector(position.x, position.y);
    PVector rayDirection = PVector.add(direction, PVector.mult(plane, (float) cameraX));
    PVector mapPosition = new PVector((int) rayPosition.x, (int) rayPosition.y);
    PVector deltaDistance = new PVector(
      sqrt(1 + sq(rayDirection.y) / sq(rayDirection.x)),
      sqrt(1 + sq(rayDirection.x) / sq(rayDirection.y)));
    PVector sideDistance = new PVector(0, 0);
    PVector step = new PVector(0, 0);
    if(rayDirection.x < 0) {
      step.x = -1;
      sideDistance.x = (rayPosition.x - mapPosition.x) * deltaDistance.x;
    } else {
      step.x = 1;
      sideDistance.x = (mapPosition.x + 1 - rayPosition.x) * deltaDistance.x;
    }
    if(rayDirection.y < 0) {
      step.y = -1;
      sideDistance.y = (rayPosition.y - mapPosition.y) * deltaDistance.y;
    } else {
      step.y = 1;
      sideDistance.y = (mapPosition.y + 1 - rayPosition.y) * deltaDistance.y;
    }
    boolean hit = false, side = false;
    // This is the meat of the DDA algorithm.
    while(!hit) {
      if(sideDistance.x < sideDistance.y) {
        sideDistance.x += deltaDistance.x;
        mapPosition.x += step.x;
        side = false;
      } else {
        sideDistance.y += deltaDistance.y;
        mapPosition.y += step.y;
        side = true;
      }
      if(world[(int) mapPosition.x][(int) mapPosition.y] > 0) hit = true;
    }
    float wallDistance;
    if(!side) {
      wallDistance = abs((mapPosition.x - rayPosition.x + (1 - step.x) / 2) / rayDirection.x);
    } else {
      wallDistance = abs((mapPosition.y - rayPosition.y + (1 - step.y) / 2) / rayDirection.y);
    }
    int lineHeight = (int) abs(height / wallDistance);
    int drawStart = max(0, -lineHeight / 2 + height / 2 + center);
    int drawEnd = min(height, lineHeight / 2 + height / 2 + center);
    color wallColor;
    switch(world[(int) mapPosition.x][(int) mapPosition.y]) {
      case 1: wallColor = color(255, 0, 0); break;
      case 2: wallColor = color(0, 255, 0); break;
      case 3: wallColor = color(0, 0, 255); break;
      case 4: wallColor = color(255, 255, 0); break;
      default: wallColor = color(255, 0, 255); break;
    }
    if(side)
      wallColor = color(red(wallColor) / 2, green(wallColor) / 2, blue(wallColor) / 2);
    for(int y = 0; y < drawStart; y++)
      pixels[y * width + x] = color(0);
    for(int y = drawStart; y < drawEnd; y++)
      pixels[y * width + x] = wallColor;
    for(int y = drawEnd; y < height; y++)
      pixels[y * width + x] = color(150, 100, 90);
  }
  updatePixels();
  if(keyMap[0]) {
    if(world[(int) (position.x + direction.x * moveSpeed)][(int) position.y] == 0)
      position.x += direction.x * moveSpeed;
    if(world[(int) position.x][(int) (position.y + direction.y * moveSpeed)] == 0)
      position.y += direction.y * moveSpeed;
  }
  if(keyMap[1]) {
    if(world[(int) (position.x - direction.x * moveSpeed)][(int) position.y] == 0)
      position.x -= direction.x * moveSpeed;
    if(world[(int) position.x][(int) (position.y - direction.y * moveSpeed)] == 0)
      position.y -= direction.y * moveSpeed;
  }
  if(keyMap[2])
    rotatePlayer((float) -rotSpeed);
  if(keyMap[3])
    rotatePlayer((float) rotSpeed);
  if(keyMap[4]) {
    PVector sideDirection = new PVector(direction.x, direction.y);
    rotate(sideDirection, radians(90));
    if(world[(int) (position.x + sideDirection.x * moveSpeed)][(int) position.y] == 0)
      position.x += sideDirection.x * moveSpeed;
    if(world[(int) position.x][(int) (position.y + sideDirection.y * moveSpeed)] == 0)
      position.y += sideDirection.y * moveSpeed;
  }
  if(keyMap[5]) {
    PVector sideDirection = new PVector(direction.x, direction.y);
    rotate(sideDirection, radians(-90));
    if(world[(int) (position.x + sideDirection.x * moveSpeed)][(int) position.y] == 0)
      position.x += sideDirection.x * moveSpeed;
    if(world[(int) position.x][(int) (position.y + sideDirection.y * moveSpeed)] == 0)
      position.y += sideDirection.y * moveSpeed;
  }
  center = (int) (map(mouseY, 0, height, height / 2, -height / 2) * mouseSensitivity);
  float rotationAmount = radians(map(pmouseX - mouseX, 0, width, 0, 360) * mouseSensitivity);
  rotatePlayer(rotationAmount);
}
void rotatePlayer(float a) {
  rotate(direction, a);
  rotate(plane, a);
}
void rotate(PVector v, float a) {
  float o = v.x;
  v.x = v.x * cos(a) - v.y * sin(a);
  v.y = o * sin(a) + v.y * cos(a);
}
void keyPressed() {
  if(key == CODED) {
    switch(keyCode) {
      case UP: keyMap[0] = true; break;
      case DOWN: keyMap[1] = true; break;
      case RIGHT: keyMap[2] = true; break;
      case LEFT: keyMap[3] = true; break;
    }
  } else {
    switch(key) {
      case 'w': keyMap[0] = true; break;
      case 's': keyMap[1] = true; break;
      case 'd': keyMap[2] = true; break;
      case 'a': keyMap[3] = true; break;
      case 'q': keyMap[4] = true; break;
      case 'e': keyMap[5] = true; break;
    }
  }
}
void keyReleased() {
  if(key == CODED) {
    switch(keyCode) {
      case UP: keyMap[0] = false; break;
      case DOWN: keyMap[1] = false; break;
      case RIGHT: keyMap[2] = false; break;
      case LEFT: keyMap[3] = false; break;
    }
  } else {
    switch(key) {
      case 'w': keyMap[0] = false; break;
      case 's': keyMap[1] = false; break;
      case 'd': keyMap[2] = false; break;
      case 'a': keyMap[3] = false; break;
      case 'q': keyMap[4] = false; break;
      case 'e': keyMap[5] = false; break;
    }
  }
}
