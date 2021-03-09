PGraphics ripples;
PGraphics outline;
PGraphics materials;
PGraphics palette;

float[][] current;
float[][] previous;

boolean rock = false;
boolean rockFall = false;
boolean stick = false;
boolean grab = false;

float s = 1;
float a = 1;

float dampening = 0.96;

float rockX;
float rockY;
float rockSize;

float stickX;
float stickY;
float stickWidth;
float stickHeight;

int fallX;
int fallY;

int dragX;
int dragY;

enum Colors {
	GREY, RED, GREEN;
}

Colors col = Colors.GREY;

float greyX;
float redX;
float greenX;
float colorY;
float colorSize;
float clearX;
boolean clear = false;;

void setup() {
	size(1920, 1080);
	// fullScreen();
	ripples = createGraphics(width, height);
	outline = createGraphics(width, height);
	palette = createGraphics(width, height);
	materials = createGraphics(width, height);
	current = new float[width][height];
	previous = new float[width][height];
	rockX = width*0.8;
	rockY = height/3;
	rockSize = width/20;
	stickX = width*0.8-(rockSize/10);
	stickY = height/2;
	stickWidth = width/100;
	stickHeight = height/3;
	greyX = width*0.6;
	redX = width*0.65;
	greenX = width*0.7;
	clearX = width*0.75;
	colorY = height/10;
	colorSize = width/40;
}

void draw() {
	background(0);

	ripples.beginDraw();
	ripples.loadPixels();
	for (int i = 1; i < width-1; i++) {
		for (int j = 1; j < height - 1; j++) {
			current[i][j]  = (
				previous[i-1][j] +
				previous[i+1][j] +
				previous[i][j-1] +
				previous[i][j+1]) / 2 -
				current[i][j];
			current[i][j] = current[i][j] * dampening;
			int index = i + j * width;
			int c = color(current[i][j]);
			if (clear) {
				c = color(0);
				current[i][j] = 0;
				previous[i][j] = 0;
			}
			if (c == color(0)) {
				ripples.pixels[index] = color(3, 16, 79);
			} else {
				if (col == Colors.GREY) {
					if (c > color(150)) {
						ripples.pixels[index] = color(c*0.95, c*0.95, c);
					} else {
						ripples.pixels[index] = color(c/26, c/5, 255-c);
					}
				} else if (col == Colors.RED) {
					ripples.pixels[index] = color(255-c, 0, 0);
				} else if (col == Colors.GREEN) {
					ripples.pixels[index] = color(0, 255-c, 0);
				}
			}
		}
	}
	clear = false;
	ripples.updatePixels();

	float[][] temp = previous;
	previous = current;
	current = temp;
	ripples.endDraw();

	outline.beginDraw();
	outline.fill(0);
	outline.rect(width/2 + width/20, 0, width/2, height);  // right side
	outline.rect(0, 0, width, height/10);  // top
	outline.rect(0, height/2 + height/3, width, height/2);  // bottom
	outline.rect(0, 0, width/20, height);  // left wide
	outline.fill(#a68064);  // wood color
	outline.noStroke();
	outline.rect(width/40, height/20, width/2 + width/30, height/20); // top
	outline.rect(width/40, height/20, height/20, width/2 - width/20); // left
	outline.rect(width/40, width/2 - width/20, width/2 + width/30, height/20); // bottom
	outline.rect(width/30 + width/2, height/20, height/20, width/2 - width/20); // right
	outline.endDraw();

	materials.beginDraw();
	materials.clear();
	// rock
	if (col == Colors.GREY) {
		materials.fill(169,169,169);
	} else if (col == Colors.RED) {
		materials.fill(255, 0, 0);
	} else if (col == Colors.GREEN) {
		materials.fill(0, 255, 0);
	}
	s = 1;
	if (rockFall) {
		a = a + 0.00001;
		s = cos(a);
	}
	rockSize *= s;
	if (rockSize <= 5) {
		splash();
		rockX = width*0.8;
		rockY = height/3;
		rockSize = width/20;
		rockFall = false;
	}
	if (rock) {
		rockX = mouseX;
		rockY = mouseY;
	}
	materials.ellipse(rockX, rockY, rockSize, rockSize);
	// stick
	if (grab) {
		stickX = mouseX;
		stickY = mouseY - stickHeight/2;
	}
	materials.fill(#825201);
	materials.rect(stickX, stickY, stickWidth, stickHeight);
	materials.endDraw();

	palette.beginDraw();
	palette.fill(169, 169, 169);  // grey
	palette.rect(greyX, colorY, colorSize, colorSize);
	palette.fill(255, 0, 0);  // red
	palette.rect(redX, colorY, colorSize, colorSize);
	palette.fill(0, 255, 0);  // green
	palette.rect(greenX, colorY, colorSize, colorSize);
	palette.fill(0);
	palette.stroke(255);
	palette.rect(clearX, colorY, colorSize, colorSize);  // clear
	palette.rect(width*0.8 - width/200, height/2, width/100, height/3);  // stick
	palette.fill(255);
	palette.text("CLEAR",clearX + colorSize/12, colorY + colorSize/2 + 4);
	palette.endDraw();

	image(ripples, 0, 0);
	image(outline, 0, 0);
	image(palette, 0, 0);
	image(materials, 0, 0);
}

void mousePressed() {
	if ((mouseX > rockX) && (mouseX < (rockX + rockSize))
		&& (mouseY > rockY) && (mouseY < (rockY+rockSize))) {
		rock = true;
		grab = false;
	} else if (!rock && (mouseX > stickX) && (mouseX < (stickX + stickWidth))
		&& (mouseY > stickY) && (mouseY < (stickY+stickHeight))) {
		stick = true;
	} else if ((mouseX > greyX) && (mouseX < (greyX + colorSize))
		&& (mouseY > colorY) && (mouseY < (colorY + colorSize))) {
		col = Colors.GREY;
	} else if ((mouseX > redX) && (mouseX < (redX + colorSize))
		&& (mouseY > colorY) && (mouseY < (colorY + colorSize))) {
		col = Colors.RED;
	} else if ((mouseX > greenX) && (mouseX < (greenX + colorSize))
		&& (mouseY > colorY) && (mouseY < (colorY + colorSize))) {
		col = Colors.GREEN;
	} else if ((mouseX > clearX) && (mouseX < (clearX + colorSize))
		&& (mouseY > colorY) && (mouseY < (colorY + colorSize))) {
		clear = true;
	}
	if ((mouseX > width/2) && (mouseY > height/2)) {
		if (!grab) {
			grab = true;
		} else {
			grab = false;
			stickX = width*0.8-(rockSize/10);
			stickY = height/2;
			stickWidth = width/100;
			stickHeight = height/3;
		}
	} else if ((mouseX > width/2) && (mouseX < width)
		&& (mouseY > (colorY + colorSize)) && (mouseY < height/2)) {
		if (!rock) {
			rock = true;
		} else {
			rock = false;
		}
	} else if (mouseX < width/2) {
		if (rock) {
			rock = false;
			rockFall = true;
			fallX = mouseX;
			fallY = mouseY;
		}
	}
}

void mouseDragged() {
	if (!stick && (mouseX > rockX) && (mouseX < (rockX + rockSize))
		&& (mouseY > rockY) && (mouseY < (rockY+rockSize))) {
		rock = true;
	}
	if (rock) {
		rockX = mouseX;
		rockY = mouseY;
	}
	if (grab) {
		int stickPointX = mouseX + width/200;
		int stickPointY = mouseY - height/6;
		if (!(stickPointX <= 0) && !(stickPointY >= width)
			&& !(stickPointY <= 0) && !(stickPointY >= height)) {
			previous[stickPointX][stickPointY] = 200;
		}
	}
}

// void mouseReleased() {
// 	if (rock) {
// 		rock = false;
// 		rockFall = true;
// 		fallX = mouseX;
// 		fallY = mouseY;
// 	} else if (stick) {
// 		stick = false;
// 	}
// }

void splash() {
	current[fallX][fallY] = 500;
}
