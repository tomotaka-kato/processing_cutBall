ArrayList<Ball> balls;

int maxCount = 5; // 一度に表示されるボールの最大数。

final ArrayList<Integer> xPositions = buildXPositions(500);; // ボールを表示するx軸の候補。

void setup() {
  size(500, 800);
  background(255);

  balls = new ArrayList<Ball>();
  for (int i = 0; i < 1; i++) {
    balls.add(new Ball());
  }
}

/**
 * メイン描画処理
 */
void draw() {
  background(255);

  if(balls.size() < maxCount + 1) {
    int createNum = (int)random(maxCount - balls.size());
    for (int i = 0; i < createNum; i++) {
      balls.add(new Ball());
    }
  }


  for(int i = 0; i < balls.size(); i++) {
    Ball ball = balls.get(i);
    ball.cut(mouseX, mouseY);
    ball.move();
    ball.draw();
    if(ball.shouldDRemove) {
      balls.remove(i);
    }
  }
}


/**
 * ボール表示のX座標を特定のパターンに固定する。
 */
ArrayList<Integer> buildXPositions(int windowWidth) {
  int base = (int) (windowWidth / 6);
  ArrayList<Integer> ret = new ArrayList<Integer>();
    ret.add(base);
    ret.add(base * 2);
    ret.add(base * 3);
    ret.add(base * 4);
    ret.add(base * 5);
  return ret;
}


/**
 * 二点間の距離を求める
 */
float calcDistance(int pos1X, int pos1Y, int pos2X, int pos2Y) {
  return sqrt(sq(pos1X - pos2X) + sq(pos1Y - pos2Y));
}


/**
 * ボールクラス
 */
class Ball {
  public boolean shouldDRemove;

  int  posX;
  int  posY;
  int  initialPosY;
  float  diameter;
  float  initialVelocityY;
  float  velocityY;
  // 色
  int colorR;
  int colorG;
  int colorB;
  int opacity;

  float  liveTime;  // 作られてからの時間。y = (1/2)gt^2のtに使用する。

  boolean isCutStart;
  int cutStartX;
  int cutStartY;
  boolean isCutted;

  float scale = 1;


  /**
   * コンストラクタ
   */
  public Ball() {
    resetCut();
    this.diameter = random(50) + 50;
    // Yはある程度深さを持たせることで画面に出てくるタイミングを変更する。
    posX = xPositions.get((int)random(xPositions.size())); // (int)(diameter/2 + random(width - diameter/2));
    initialPosY = (int)(height + diameter/2 + random(50));
    posY = initialPosY; 
    initialVelocityY = -300 - random(4) * 100;
    velocityY = initialVelocityY;
    // TODO: 白系の色が生成されないようにする。
    this.colorR = 100 + (int) random(156);
    this.colorG = 100 + (int) random(156);
    this.colorB = 100 + (int) random(156);
  }

  /**
   * ボールの座標移動
   */
  public void move() {
    if(isCutted) {
      this.scale += 0.2;
      this.diameter *= this.scale;

      this.shouldDRemove = this.scale > 1.5;

    } else {
      liveTime += 1/(float)60;

      float g = 9.8 * 20 ; // 重力加速度。9.8のままだと9.8pixel/sとなって遅いので、係数をかけて大きさを調整。
      velocityY = initialVelocityY + g * liveTime; 
      posY = (int)(initialPosY + (g * liveTime * liveTime / 2) + initialVelocityY * liveTime);
      this.shouldDRemove = isDropOut();
    }

  }

  /**
   * ボールの描画処理
   */
  public void draw() {
      noStroke();
      fill(colorR, colorG, colorB);
      ellipse(posX, posY, diameter, diameter);
  }

  /**
   * 下に落ちたかどうか
   */
  public Boolean isDropOut() {
    return velocityY > 0 && posY > height + diameter;
  }

  /*
   * ボールの切断処理
   */
  public void cut(int mousex, int mousey) {
    if(!this.isCutStart && isInnerBall(mousex, mousey)) {
      this.isCutStart = true;
      // 切断開始の座標を保持
      this.cutStartX = mousex;
      this.cutStartY = mousey;
    } else if(isCutStart && !isInnerBall(mousex, mousey)) {
      // 切断処理が開始されていて、かつボールの外にマウスカーソルが移動したら切断判定
      // マウスがボールに当たった位置から直線で直径の1/2を通過していたら切断処理成功とする。
      int diffX = mousex - cutStartX;
      int diffY = mousey - cutStartY;
      if(sqrt(diffX * diffX + diffY * diffY) > this.diameter / 2) {
        this.isCutted = true;
      } else {
        resetCut();
      }
    }
  }

  /**
   * 切断開始処理のフラグ初期化
   */
  private void resetCut() {
    this.isCutStart = false;
  }

  private boolean isInnerBall(int mousex, int mousey) {
    return calcDistance(posX, posY, mousex, mousey) <= diameter/2;
  }
}
