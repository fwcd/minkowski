// Class declarations

class Point {
    float x;
    float ct;
    
    Point(float x, float ct) {
        this(x, ct, false);
    }
    
    Point(float x, float ct, boolean fromScreenCoords) {
        if (fromScreenCoords) {
            this.x = x - padding;
            this.ct = -(ct - height + padding);
        } else {
            this.x = x;
            this.ct = ct;
        }
    }
    
    float getX() {
        return x;
    }
    
    float getCT() {
        return ct;
    }
    
    Point transform(float v) {
        float beta = v / c;
        float gamma = 1 / sqrt(1 - (beta * beta));
        return new Point(
                gamma * (x - (beta * ct)),
                gamma * (ct - (beta * x))
        );
    }
    
    float toScreenX() {
        return x + padding;
    }
    
    float toScreenY() {
        return height - padding - ct;
    }
    
    void paint(int r, int g, int b, float pointSize) {
        stroke(r, g, b);
        fill(r, g, b);
        ellipse(toScreenX(), toScreenY(), pointSize, pointSize);
    }
    
    void paintText(String str, float size) {
        textSize(size);
        text(str, toScreenX(), toScreenY());
    }
}

class CoordSystem {
    final float granularity = 0.3F;
    final boolean showGrid = true;
    final float gridSpacing = 50F;
    float v;
    int r;
    int g;
    int b;
    
    CoordSystem(float v, int r, int g, int b) {
        this.v = v;
        this.r = r;
        this.g = g;
        this.b = b;
    }
    
    void paint() {
        float maxX = width - (padding * 2);
        float maxY = height - (padding * 2);
        
        paintRange(0, 0, maxX, 0, 5); // x-axis
        paintRange(0, 0, 0, maxY, 5); // y-axis
        
        new Point(maxX, 0).transform(v).paintText("x", 24);
        new Point(0, maxY).transform(v).paintText("ct", 24);
        
        if (showGrid) {
            for (int y=0; y<maxY; y+=gridSpacing) {
                paintRange(0, y, maxX, y, 1);
            }
            for (int x=0; x<maxX; x+=gridSpacing) {
                paintRange(x, 0, x, maxY, 1);
            }
        }
    }
    
    float relativeVelocity(CoordSystem other) {
        return v - other.v;
    }
    
    void trace(Point p, float dv) {
        Point pT = p.transform(dv);
        paintRange(0, pT.getCT(), pT.getX(), pT.getCT(), 3);
        paintRange(pT.getX(), 0, pT.getX(), pT.getCT(), 3);
    }
    
    void paintRange(float xA, float ctA, float xB, float ctB, float pointSize) {
        float step = 1F / granularity;
        for (float x=xA; x<=xB; x+=step) {
            for (float ct=ctA; ct<=ctB; ct+=step) {
                new Point(x, ct).transform(v).paint(r, g, b, pointSize);
            }
        }
    }
}

class Slider {
    final int w = 200;
    final int h = 10;
    int x;
    int y;
    int sliderX;
    int sliderY;
    float min;
    float max;
    float value;
    
    Slider(int x, int y, float min, float max) {
        this.x = x;
        this.y = y;
        sliderX = x;
        sliderY = y;
        this.min = min;
        this.max = max;
        value = min;
    }
    
    float getValue() {
        return value;
    }
    
    boolean contains(int x, int y) {
        return x >= this.x && x <= (this.x + w)
                && y >= this.y && y <= (this.y + h);
    }
    
    void paint(String suffix) {
        stroke(128);
        fill(128);
        rect(x, y, w, h);
        
        if (mousePressed && contains(mouseX, mouseY)) {
            sliderX = mouseX;
            value = (((sliderX - x) / (float) w) * (max - min)) + min;
        }
        
        stroke(0);
        fill(0);
        textSize(14);
        text(String.format("%.2f", value) + suffix, x + w + 10, y + h);
        rect(sliderX, sliderY, h, h);
    }
}

// Variable declarations

final float c = 299792458; // Speed of light
final int padding = 50;
final Slider slider = new Slider(10, 10, -c, c);
final CoordSystem observerSystem = new CoordSystem(0, 100, 100, 100);
Point point = null;

// Method declarations

void setup() {
    size(640, 480);
}

void draw() {
    clear();
    fill(255);
    stroke(255);
    rect(0, 0, width, height);
    
    CoordSystem movingSystem = new CoordSystem(slider.getValue(), 0, 0, 255);
    observerSystem.paint();
    movingSystem.paint();
    
    fill(255);
    stroke(255);
    rect(0, 0, width, 22);
    slider.paint(" m/s");
    
    if (point != null) {
        movingSystem.trace(point, observerSystem.relativeVelocity(movingSystem));
        point.paint(128, 0, 255, 15);
    }
    
    if (mousePressed && mouseButton == RIGHT) {
        point = new Point(mouseX, mouseY, true);
    }
}