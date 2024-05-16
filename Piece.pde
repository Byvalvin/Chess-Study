 //PIECE OBJECT BASE CLASS

class Piece{
  
  PImage P; // all pieces have a representive image
  
  // (pixelized)location of the image of the piece. in two forms so the location can be returned as an array of 2 floats + drawing and moving images is a pain
  float loc_x; float loc_y;
  float[] loc = {loc_x,loc_y};
  
  int C; // colour, 0 or 255/ light or dark
  
  boolean captured = false; //All pieces start alibe
  
  boolean selected = false; // by default no piece is selected yet; selected = is being moved
  
  float squaresize; // for showing and display purposes, this is the length of the square I stan on
  
  ArrayList<Sq> moves = new ArrayList<Sq>(); // keeps a dynamic list of all the squares available to me given my position
  
  /*
  int counts(){
    return 0;
  */
  // METHODS()all piece share these methods
  //constructor
  Piece(PImage P_, float x, float y, int colour){
    P = P_; // my image
    
    loc_x = x; loc_y = y; // center
    loc[0] = x-squaresize/2; loc[1] = y-squaresize/2; //corner
    
    C = colour; // my colour
  }
  
  
  // return my coulur
  int getC(){
    return C;
  }
  
  //return my piexelize dlocation
  float[] getLoc(){
    return loc;
  }
  
  // change my pixelized location
  void changeLoc(float newlx, float newly){ //centrecoords change
    loc_x = newlx; loc_y = newly;// center
    loc[0] = newlx-squaresize/2; loc[1] = newly-squaresize/2; // corner
  }
  
  // when piece is captured
  void out(){
    captured = true;
  }
  
  // display piece
  void show(){
    if(!captured){
      imageMode(CENTER);
      
      image(P,loc_x,loc_y);
      
    }
  }
  
  // set the length of square piece is on
  void setSquaresize(float N){
    squaresize = N;
  }
  
  void select(int X, int Y){
    selected = mousePressed && (loc_x-squaresize/2)<X && X<(loc_x+squaresize/2)  &&  (loc_y-squaresize/2)<Y &&Y<(loc_y+squaresize/2);
  }
  
  void setSelect(boolean bool){
    selected = bool;
  }


  
  // generic movement/ movement before placing on proper square. Will help determine the square piece is actaully on
  float[] movement(){ 
    
    
    
    if((loc_x-squaresize/2)<mouseX && mouseX<(loc_x+squaresize/2)   &&   (loc_y-squaresize/2)<mouseY && mouseY<(loc_y+squaresize/2) && selected){
      //if(this.getClass()==Bishop.class && getCurrSq().get_matrix_loc()[1]!=7)println("this works");
      loc_x = mouseX; loc_y = mouseY;
      loc[0] = loc_x-squaresize/2; loc[1]=loc_y-squaresize/2;
        
    }
    
    //if(this.getClass()==Bishop.class && getCurrSq().get_matrix_loc()[1]!=7 && C==0)println(getLoc());
    return getLoc();
  
  }
  
  
  boolean IsSelected(){
    return selected;
  }
  
  /*
  void select(boolean b){
    selected = b;
  }
  */
  
  // return the moves currently availabke to this piece
  ArrayList<Sq> getMoves(){
    return moves;
  }
  // add a square as a possible destination for piece
  void add_move(Sq square){
    if(!moves.contains(square))moves.add(square);
  }
  // base method to update the avaible moves. The actual methods are in the Piece's Super class(es)
  void updateMoves(Sq[][] S, Sq square){
  }
  
  // return the square piece is currently on
  Sq getCurrSq(){
    return moves.get(0); // MAKE SURE THE FIRST POSSIBLE MOVE IS THE SQUARE PIECE IS ALREADY ON
  }
  // rest the available moves
  void resetMoves(){
    moves.clear();
  }
  
  // FOR PAWNS ONLY, no..., also King and Rook for castling
  void first_moved(){
  }
  void first_again(){
  }
  
  boolean moved(){
    return false;
  }
  
  boolean startSq(int xi, int yi){
    return true;
  }
  //
  
  void setCapture(boolean cap){
    captured = cap;
  }
  
  // FIX for pieces not moving after captures
  boolean active(){
    return !captured;
  }
  
  // PAWN ONLY
  boolean just_jumped(){
    return false;
  }
  void set_jump(boolean bool){
  }
  
  boolean canEPSLeft(){
    return false;
  }
  boolean canEPSRight(){
    return false;
  }


  void set_EnPassantLeft(boolean e){
  }
  void set_EnPassantRight(boolean e){
  }
  
  int getfirstEPSn(){
    return 27;
  }
  
  int availableMoves(){
    return moves.size()-1;
  }
  
  int getN(){
    return 0;
  }
  

  
}

// POSITIONAL NOTES
// In reference to white;
// FORWARD:  up going down, y: 0->inf

// In reference to black;
// LEFT: viewer's left/ L -> R ====> x: 0->inf

// PAWNS(complete for now)
class Pawn extends Piece{
  int Player;
  boolean first_move = true;
  boolean jumped = false; // jump on forst move 
  int count = 0;
  
  int lEPS=0; int rEPS=lEPS;
  
  boolean firstEPS = true; int firstEPSn = 2;
  boolean canEnPassantLeft = true; boolean canEnPassantRight = true;
  boolean canEnPassantExtra = true;
  int n;
  
  //BASIC CONSTRUCTOR
  Pawn(PImage P_, float x, float y, int colour, int n_){
    super(P_, x, y, colour);
    
    n = n_; // indicates which pawn is which, since they are all the same looking...

    //Player = Player_;

   
  }
  
  /*
  int counts(){
    return lEPS;
  }
  */

  
  
  // Pawn moves up squares, one square at a time, and cannot go back
  // Supers override method to update it's available moves
  void updateMoves(Sq[][] S, Sq square){
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    moves.clear(); // always clear whats already their

    moves.add(square); // add current square, will use to warp back here if needed
    
    // FOR CAPTURES
    if(C!=0){
      //WHITE
      if(xi-1>=0 && yi+1<S.length){//white right
        Sq right_up_w = S[xi-1][yi+1];
        if(right_up_w.hasPiece() && right_up_w.getPiece().getC()==0){
          moves.add(S[xi-1][yi+1]);
        } 
      }
      if(xi+1<S.length && yi+1<S.length){//white left
        Sq left_up_w = S[xi+1][yi+1];
        if(left_up_w.hasPiece() && left_up_w.getPiece().getC()==0){
          moves.add(S[xi+1][yi+1]);
        }
      }
    }else{
      //BLACK
      if(xi-1>=0 && yi-1>=0){//black left
        Sq left_up_b = S[xi-1][yi-1];
        if(left_up_b.hasPiece() && left_up_b.getPiece().getC()!=0){
          moves.add(S[xi-1][yi-1]);
        } 
      }
      if(xi+1<S.length && yi-1>=0){//black right
        Sq right_up_b = S[xi+1][yi-1];
        if(right_up_b.hasPiece() && right_up_b.getPiece().getC()!=0){
          moves.add(S[xi+1][yi-1]);
        }
      }
    }
    
    //println(canEnPassantLeft);
    // capturing EN PASSANT;
    
    if(game.can_EnPassantLeft(this,C)){
      // which came first
      if(firstEPS==true){
        firstEPSn = 0;
        firstEPS=false;
      }
      
      if(canEnPassantLeft){
        add_move(game.EnPassantSqLeft(this, C)); // add an extra attack square
        lEPS++;
        if(lEPS==2){
          canEnPassantLeft = false;
        }
      }
      
      // in case of enpassant problems?
      
      //if(canEnPassantLeft || canEnPassantExtra){
      //  add_move(game.EnPassantSqLeft(this, C)); // add an extra attack square
        
      //  if(canEnPassantLeft==true && canEnPassantExtra==true){
      //    canEnPassantLeft = false;
      //  }else{
      //    canEnPassantExtra = false;
      //  }
        
        
      //}
      
  
      

    }
    if(game.can_EnPassantRight(this,C)){
      // which came first
      if(firstEPS==true){
        firstEPSn = 1;
        firstEPS=false;
      }
      
      if(canEnPassantRight){
        
        add_move(game.EnPassantSqRight(this, C)); // add an extra attack square
        rEPS++;
        if(rEPS==2){
          canEnPassantRight = false;
        }
      }
      
    }
    
  
    
    if(!first_move){
      //println(C,n,"not first");
      
      
      // get THE ONE square DIRECTLY IN FRONT, if first pawn move, can do the teo squares directly in front, Captures*LATER, Promotion*LATER
      //boolean w_blocked = S[xi][yi+1].hasPiece(); boolean b_blocked = S[xi][yi-1].hasPiece();
      
      if(yi+1 < S.length && C!=0 && !(S[xi][yi+1].hasPiece()) ){//WHITE PAWN DOWN
        add_move(S[xi][yi+1]);
        
      }else if(yi-1 >= 0 && C==0 && !(S[xi][yi-1].hasPiece()) ){//BLACK PAWN UP
        add_move(S[xi][yi-1]);
      }
      
      
    }else{
      // just add squares(if not blocked)
       
      if(C==0){//if black
        
        boolean b_blocked = S[xi][yi-1].hasPiece(); boolean b_blocked2 = S[xi][yi-2].hasPiece();
       
        if(!b_blocked)moves.add(S[xi][yi-1]);
        if(!b_blocked && !b_blocked2)moves.add(S[xi][yi-2]);
      }else{//if white
        
        boolean w_blocked = S[xi][yi+1].hasPiece(); boolean w_blocked2 = S[xi][yi+2].hasPiece();
        
        if(!w_blocked)moves.add(S[xi][yi+1]);
        if(!w_blocked && !w_blocked2)moves.add(S[xi][yi+2]); // jump square is the last square added usually
      }
    }
      
    game.attack(C); // attack the King?
    
    
    
  }
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
  void first_moved(){
    first_move = false;
  }
  
  void first_again(){
    first_move = true;
  }
  
  boolean startSq(int xi, int yi){
    int y;
    if(C==0){
      y = 6; //bottom
    }else{
      y = 1; // top
    }
    return xi == n && yi == y;
  }
  
  boolean moved(){
    return !first_move;
  }
  
  // PAWN ONLY
  boolean just_jumped(){
    return jumped;
  }
  void set_jump(boolean j){
    if(jumped==j){
      jumped=j;
      
    }else if(!jumped && j){
      count++;
      jumped = j;
      
    }else if(jumped && !j){ // wait 1 turn
      if(count==2){
        jumped=j;
        
      }else{
        count++;
      }
    }
  }
  boolean canEPSLeft(){
    return canEnPassantLeft;
  }
  boolean canEPSRight(){
    return canEnPassantRight;
  }
  void set_EnPassantLeft(boolean e){
    canEnPassantLeft=e;
  }
  void set_EnPassantRight(boolean e){
    canEnPassantRight=e;
  }
  
  int getfirstEPSn(){
    return firstEPSn;
  }
  
  int getN(){
    return n;
  }
  

  
}
  
  
  
  
// PIECE SUB CLASSES
  
// KNIGHTS(Incomplete)
class Knight extends Piece{
  
  //CONSTRUCTOR(Already done) just a basic constructor, will add more detail later
  Knight(PImage P_, float x, float y, int colour){
    super(P_, x, y, colour);
    //Player = Player_;
  }
  /*  FOR MARK
  Before beginning, you''l need to review the code for 2 classes. Ideally, you should probably know the code for all the classes... but these two are most important for this part
  A) Sq class: squares on the chessboard are an object in of themselves. See their attributes and what they can do
  B) Piece class: the base class for all pieces. Definitely must know what all pieces can do before sub-specializing to individual pieces
  
  None of these are set in stone. If you feel the need to add some more functionality or edit what is already there, do so. Just dont forget to comment what you did and why so we are on the same page
  */
  //1)UPDATE MOVES(input: a matrix of squares(the board), the square the piece is currently on(used for snaping back if illegal move made)| Output: None, updates moves(an ArrayList<Sq> object of legal squares))
  //See updateMoves() for Bishop for example
  //This is called after empty move is made, as the piece will need to know where it can/cant go in any given iteration
  //GOAL: determine all the squares this piece can go to on the board(given the square it is currently on) and add those squares to the pieces "moves" attribute. 
  // ****Make sure to reset the moves list before adding new moves*****
  
  //2)RESET MOVES
  //See resetMoves() for Bishop for example
  //GOAL: empty the moves list of the piece
  
  
  
  
  
  void updateMoves(Sq[][] S, Sq square){
    moves.clear();
    
    // add current square, will use to warp back here if needed
    moves.add(square);
    
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    
    if( (xi-2) >= 0 ){
      if((yi-1) >= 0){
        add_move(S[xi-2][yi-1]);      // v__o
      }  
      if((yi+1) < S.length){
        add_move(S[xi-2][yi+1]);      // ^__o
      }
    }
      
    if( (xi-1) >= 0 ){
      if((yi-2)>=0){
        add_move(S[xi-1][yi-2]);      // ^^_o
      }
      if((yi+2) < S.length){
        add_move(S[xi-1][yi+2]);      // vv_o
      }
    }
      
    
    
    if( (xi+2) < S.length){
      if((yi-1) >= 0){
        add_move(S[xi+2][yi-1]);      // o__^ 
      }  
      if((yi+1) < S.length){
        add_move(S[xi+2][yi+1]);      // o__v 
      }
    }
    
    if((xi+1) < S.length){
      if((yi-2)>=0){
        add_move(S[xi+1][yi-2]);      // o_^^
      }
      if((yi+2) < S.length){
        add_move(S[xi+1][yi+2]);      // o_vv
      }
    }
      
    
    game.attack(C); // attack the King?
    
  }
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
}


// BISHOPS(complete)
class Bishop extends Piece{
  int Player;
  boolean start = true;
  
  // has a moves arraylistlist of available squares to the Bishop
  
  // BASIC CONSTRUCTOR
  Bishop(PImage P_, float x, float y, int colour){
    super(P_, x, y, colour);
    //Player = Player_;
  }
  
  // Bishop moves on diagonals of its start colour ONLY
  // Supers override method to update it's available moves
  void updateMoves(Sq[][] S, Sq square){
    moves.clear();
    
    // add current square, will use to warp back here if needed
    moves.add(square);
    
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    // get all squares from all(4) directions, one direction at a time, until we get to board egdes/sides
    int tl_x = xi-1; int tl_y = yi-1;
    int tr_x = xi+1; int tr_y = yi-1;
    int bl_x = xi-1; int bl_y = yi+1;
    int br_x = xi+1; int br_y = yi+1;
    
    //STOP when blocked in any of the directions
    boolean blocked = false;
    Sq next; Piece P;
    
    // first lets do all squares towards top left 
    // both xi and yi go down by one
    
    while( (tl_x>=0 && tl_y>=0) && !blocked ){
      next = S[tl_x--][tl_y--];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocking
    
    //second all squares towards top right
    // xi up, yi down
    while( (tr_x < S.length && tr_y>=0) && !blocked ){
      next = S[tr_x++][tr_y--];
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocking
    
    
    // third all squares towards bottom left
    // xi down, yi up
    while( (bl_x>=0 && bl_y < S.length) && !blocked ){
      next=S[bl_x--][bl_y++];
      
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false;
    
    
    
    // fourth and final, bottom tight
    // xi up, yi up
    while( (br_x < S.length && br_y < S.length) && !blocked ){
      next=S[br_x++][br_y++];
      
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    game.attack(C); // attack the King?
    /*
    println(C,Bishop.class);
    for(int i=0; i<moves.size(); i++){
      println(moves.get(i).get_matrix_loc());
    }
    */
    
  }
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
  
  
  
}

// ROOKS(Incomplete)
class Rook extends Piece{
  
  boolean first_move = true;
  
  //CONSTRUCTOR(Already done) just a basic constructor, will add more detail later
  Rook(PImage P_, float x, float y, int colour){
    super(P_, x, y, colour);
    //Player = Player_;
  }
  
  
  void updateMoves(Sq[][] S, Sq square){
    moves.clear();
    
    // add current square, will use to warp back here if needed
    moves.add(square);
    
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    //STOP when blocked in any of the directions
    boolean blocked = false;
    Sq next; Piece P;
    
    // get all squares from all(4) directions, one direction at a time, until we get to board egdes/sides
    int tl_x = xi-1; //int tl_y = yi; //adjusted to left_only
    int tr_y = yi-1; //adjusted to top_only //int tr_x = xi;
    int bl_y = yi+1; //adjusted to bottom_only //int bl_x = xi;
    int br_x = xi+1; //int br_y = yi; //adjusted to right_only
    
    // first left
    while( (tl_x>=0) && !blocked){
      next = S[tl_x--][yi];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
      
    }
    
    blocked = false; // reset blocks
    
    // straight up
    while( (tr_y>=0) && !blocked){
      next = S[xi][tr_y--];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocks
    
    // down we go
    while( (bl_y < S.length) && !blocked ){
      next = S[xi][bl_y++];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    
    blocked = false; // reset blocks
    
    // right is right
    while( (br_x < S.length) && !blocked ){
      next = S[br_x++][yi];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
      
    }
    
    
    game.attack(C); // remove squares the rook attacks from the king
    
  }
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
  
  boolean moved(){
    return !first_move;
  }
  
  void first_moved(){
    first_move = false;
  }
  
  
}

// QUEEN(Incomplete)
class Queen extends Piece{
  
  //CONSTRUCTOR(Already done) just a basic constructor, will add more detail later 
  Queen(PImage P_, float x, float y, int colour){
    super(P_, x, y, colour);
    //Player = Player_;
  }

  
  void updateMoves(Sq[][] S, Sq square){
    moves.clear();
    
    // add current square, will use to warp back here if needed
    moves.add(square);
    
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    // get all squares from all(4) directions, one direction at a time, until we get to board egdes/sides
    int tl_x_b = xi-1; int tl_x_r = xi-1;            int tl_y = yi-1;
    int tr_x = xi+1;                                 int tr_y_b = yi-1; int tr_y_r = yi-1;
    int bl_x = xi-1;                                 int bl_y_b = yi+1; int bl_y_r = yi+1;
    int br_x_b = xi+1; int br_x_r = xi+1;            int br_y = yi+1;
    
    //STOP when blocked in any of the directions
    boolean blocked = false;
    Sq next; Piece P;
    
    
    // LIKE A BISHOP
    
    // first lets do all squares towards top left 
    // both xi and yi go down by one
    
    while( (tl_x_b >=0 && tl_y>=0) && !blocked ){
      next = S[tl_x_b--][tl_y--];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocking
    
    //second all squares towards top right
    // xi up, yi down
    while( (tr_x < S.length && tr_y_b>=0) && !blocked ){
      next = S[tr_x++][tr_y_b--];
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocking
    
    
    // third all squares towards bottom left
    // xi down, yi up
    while( (bl_x>=0 && bl_y_b < S.length) && !blocked ){
      next=S[bl_x--][bl_y_b++];
      
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false;
    

    // fourth and final, bottom tight
    // xi up, yi up
    while( (br_x_b < S.length && br_y < S.length) && !blocked ){
      next=S[br_x_b++][br_y++];
      
      
      if(next.hasPiece()){
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next);
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // odd cond for King
            blocked = true;
          }
        }
        
      }else{
        add_move(next);
      }
    }
    
    // LIKE A ROOK
    
    blocked = false;
    
    // first left
    while( (tl_x_r>=0) && !blocked){
      next = S[tl_x_r--][yi];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
      
    }
    
    blocked = false; // reset blocks
    
    // straight up
    while( (tr_y_r>=0) && !blocked){
      next = S[xi][tr_y_r--];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    blocked = false; //reset blocks
    
    // down we go
    while( (bl_y_r < S.length) && !blocked ){
      next = S[xi][bl_y_r++];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
    }
    
    
    blocked = false; // reset blocks
    
    // right is right
    while( (br_x_r < S.length) && !blocked ){
      next = S[br_x_r++][yi];
      
      if(next.hasPiece()){ // blocked but need to know if by black or white
        P=next.getPiece();
        
        if(game.sameC(this,P)){
          add_move(next); 
          blocked = true;   // add next Sq BUT wont be able to move there(for defending)
        }else{
          add_move(next); // add next Sq but stop there
          if(P.getClass()!=King.class){ // ODD CONDITION FOR KINGS ONLY
            blocked = true;
          }
        }
        
        
      }else{
        add_move(next);
      }
      
    }
    
    
    game.attack(C); //Opposing Queen takes away squares from the King
    
  }
  
  
  
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
}

// KING(Incomplete)
class King extends Piece{
  int Player;
  boolean start = true;
  
  boolean first_move=true;
  
  // has a moves arraylistlist of available squares to the Bishop
  
  // BASIC CONSTRUCTOR
  King(PImage P_, float x, float y, int colour){
    super(P_, x, y, colour);
    //Player = Player_;
  }
  
  // Bishop moves on diagonals of its start colour ONLY
  // Supers override method to update it's available moves
  void updateMoves(Sq[][] S, Sq square){
    moves.clear();
    
    // add current square, will use to warp back here if needed
    moves.add(square);
    
    int[] square_loc = square.get_matrix_loc();
    int xi = square_loc[0]; int yi = square_loc[1];
    
    // get all squares directed adjacent to current square(total 8, + current square makes 9) 
    
    // all the directions wee need
    int tl_x = xi-1; int tl_y = yi-1;
    int tr_x = xi+1; int tr_y = yi-1;
    int bl_x = xi-1; int bl_y = yi+1;
    int br_x = xi+1; int br_y = yi+1;

    Sq next; Piece P;
    
    
    if((0<=tl_x&&tl_x<=7) && (0<=tl_y&&tl_y<=7)){
      next = S[tl_x][tl_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }        
          
        }else{
          add_move(next); // top left  <\                     start-> o -> o -> o
        }
      }
    }
    
    
    if((0<=xi&&xi<=7) && (0<=tl_y&&tl_y<=7)){
      next = S[xi][tl_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // top         ^|                             ^         |
        }
      }
    }
    
    
    if((0<=tr_x&&tr_x<=7) && (0<=tr_y&&tr_y<=7)){
      next = S[tr_x][tr_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // top right >/                             |         v
        } 
      }
    }
    
    
    if((0<=tr_x&&tr_x<=7) && (0<=yi&&yi<=7)){
      next = S[tr_x][yi];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // right ->                             end <-o    o    o
        }
      }
    }
    
    
    if((0<=br_x&&br_x<=7) && (0<=br_y&&br_y<=7)){
      next = S[br_x][br_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // bottom right \>                          ^         |
        }
      }
    }
    
    
    if((0<=xi&&xi<=7) && (0<=br_y&&br_y<=7)){
      next = S[xi][br_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // bottom |                                   |         v
        }
      }
    }
    
    
    if((0<=bl_x&&bl_x<=7) && (0<=bl_y&&bl_y<=7)){
      next = S[bl_x][bl_y];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // bottom left  </                          o -> o -> o
        }
      }
    }
    
    
    if((0<=bl_x&&bl_x<=7) && (0<=yi&&yi<=7)){
      next = S[bl_x][yi];
      if(!moves.contains(next)){
        if(next.hasPiece()){
          P = next.getPiece();
          
          if(!game.sameC(this, P)){
            add_move(next);
          }    
          
        }else{
          add_move(next); // left  <-
        }
      }
    }
    
    // FINALLY, remove all attacked sqs
    game.KingAttack();
    
    
    
    
  }
  
  // supers override method to reset available moves
  void resetMoves(){
    moves.clear();
  }
  
  void first_moved(){
    first_move = false;
  }
  
  boolean moved(){
    return !first_move;
  }
  
  
  
  
}
