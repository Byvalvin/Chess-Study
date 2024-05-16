//SQUARE OBJECT ON BOARD

class Sq{
  int[] matrix_loc = {0,0};// All squares have 2 locations: 1)pixelized-> for drawing, 2)matrix-> for access + most Sq object methods
  
  float x;
  float y; float [] cent_coord = {x,y};// pixelized locations, made two version, cent_coord is to be able to return pixelized location CENTRE of square-> for drawing image of pieces
  //the other set is the CORNER of square -> for drawing square
  
  float n; // lebgth
  int colour; // race

  Piece WarPiece = null; // all squares start without a piece, we add the piece with the "setPiece(Piece)" method
  
  boolean piece_on = false; // if I have a piece on me
  
  Sq(float _x, float _y, float len, int c, int xi_, int yi_){
    x = _x;
    y = _y; cent_coord[0] = x+n/2; cent_coord[1] = y+n/2;
    
    n  = len;
    colour = c;
    //colour, x and y location, size, image
    
    matrix_loc[0] = xi_; matrix_loc[1] = yi_;
  }
  
  // return the pixelized center location
  float [] get_cent_coord(){
    return cent_coord;
  }
  
  //return the matrix location
  int[] get_matrix_loc(){
    return matrix_loc;
  }
  
  // place a piece on this square
  void setPiece(Piece piece){
    WarPiece = piece;
    
    WarPiece.changeLoc(x+n/2,y+n/2); // squares centre is the location for the piece image
    WarPiece.setSquaresize(n);
    
    if(!WarPiece.moves.contains(this)){
      WarPiece.add_move(this);
    }
    piece_on = true;
    
  }
  
  // USE UNDER STRICT CONDITION THAT IT HAS A PIECE
  Piece getPiece(){
    return WarPiece;
  }
  
  //// select/deselcet piece on square
  //void selectPiece(boolean sel){
  //  WarPiece.select(sel);
  //}
  
  
  // check if I have a piece on me
  boolean hasPiece(){
    return piece_on;
  }
  
  // update the moves of the piece-on-me IFF I have one-on-me
  void updatePieceMoves(Sq[][] S){
    if(piece_on && WarPiece.active()){
      if(WarPiece.getClass()==Bishop.class){
        //println("a b",WarPiece.getC());
      }
      WarPiece.updateMoves(S,this);
    }else{
      //println("NO PIECE HERE!");
    }
  }
  
  // I no longer have a piece-on-me as it has been moved
  void movedPiece(){
    if( piece_on && (WarPiece.getClass() == Pawn.class || WarPiece.getClass() == King.class || WarPiece.getClass() == Rook.class) && WarPiece.IsSelected() ){
      WarPiece.first_moved(); // made first move
      //println("fmoved");
    }
    WarPiece = null;
    piece_on = false;
  }
  
  
  // display square
  void show(){
    stroke(0);
    fill(colour);
    square(x,y,n);
  }
  
  // display piece ONLY if square has one and ONLY AFTER displaying square its on
  void showPiece(){
    // image on square, show it
    if(piece_on && getPiece().active()){
      WarPiece.show();
      //image(Piece,x+n/2,y+n/2);
    }
  }
  
  int getC(){
    return colour;
  }
  
  float getN(){
    return n;
  }
  
}
