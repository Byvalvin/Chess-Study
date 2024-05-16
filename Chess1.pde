import processing.sound.*;


//GAMEPLAY SETTINGS

// Gloabally vars

//colours
int black = 0; int white = 255;
int grid = 8; // 8X8 grid

//set the window
int w_width = 1000; int w_length = w_width;
int bg_colour = black;
//int FPS = 30;



Game game;
// GAME OBJECTS INIT
int board_x = 50;  // the distance between window and board, also the x,y for first square

// length of a sq
int n = (w_width - board_x*2) / grid; // length of 1 square on board

Board ChessBoard = new Board(board_x, w_width); // Board object

// Actual Pieces

// Kings 
King WKing, BKing;

//Quuens
Queen WQueen, BQueen;

//Bishops
Bishop WBishopw, WBishopb, BBishopw, BBishopb;

//Knights
Knight WKnight1, WKnight2, BKnight1, BKnight2;

//Rooks
Rook WRook1, WRook2, BRook1, BRook2;

// White Pawns
ArrayList<Pawn> WPawns = new ArrayList<Pawn>();

// Black Pawns
ArrayList<Pawn> BPawns = new ArrayList<Pawn>();


// PIECE IMAGES
PImage WKingImage, BKingImage;
PImage WQueenImage, BQueenImage;
PImage WBishopImage, BBishopImage;
PImage WKnightImage, BKnightImage;
PImage WRookImage, BRookImage;
PImage WPawnImage, BPawnImage;


// PIECE PICS
ArrayList<String>images = new ArrayList();

String W = "W"; String B = "B";
String ext = ".png"; // high quality high mem cost->use ".jpg" as a last resort

char div = '$'; int part = 1; int splits = 2;
String picstrings[] = {split(King.class.getName(),div)[part], split(Queen.class.getName(),div)[part], split(Bishop.class.getName(),div)[part], 
split(Knight.class.getName(),div)[part], split(Rook.class.getName(),div)[part], split(Pawn.class.getName(),div)[part]};

/*
picstrings[0] = WKing.getClass().getName(); picstrings[1] = Queen.getClass.getName();
picstrings[2] = Bishop.getClass.getName(); picstrings[3] = Knight.getClass.getName();
picstrings[4] = Rook.getClass.getName();  picstrings[5] = Pawn.getClass.getName();
*/




//Players
Player p1, p2;
ArrayList<Piece> WhitePieces = new ArrayList<Piece>(); 
ArrayList<Piece> BlackPieces = new ArrayList<Piece>();
int army; // no pieces per player
// each piece list also need their movements!!!!!!

/*
ArrayList<float[]> WPieces_Finalposes = new ArrayList<float[]>();
ArrayList<float[]> BPieces_Finalposes = new ArrayList<float[]>();

*/



  
// for the pieces location
float PieceX = board_x; float PieceY = board_x; // white quuen, could really be any values since will change later

float PieceXb = board_x+400; float PieceYb = board_x+400; // black queen, again, place on board not important, Black Queen is just a movable pic, not a piece


/*
// some random functions
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}
*/

float[] centre_to_tl(float[] coords, float n){
  float[] tl_coord = {0,0};
  tl_coord[0]=coords[0]-n/2; tl_coord[1]=coords[1]-n/2;
  return tl_coord;
}

float[] tl_to_centre(float[] coords, float n){
  float[] centre_coord = {0,0};
  centre_coord[0]=coords[0]+n/2; centre_coord[1]=coords[1]+n/2;
  return centre_coord;
}
  

// SOUNDS AND SOUNDFILES

//SoundFile Satie; // can use this to test your sound code in general -> SoundFile and their methods -> https://processing.org/reference/libraries/sound/SoundFile.html
//SOUND STUFFF
SoundFile move, illegal, check, capture, mate, stale;
String move_sound = "move_test_cut4.wav"; String check_sound = "check_test_cut2.wav"; String mate_sound = "mate_test_cut.wav"; String stale_sound = "stale_test_cut.wav"; String no = "error.wav";
String cap_sound = "mate_test_cut.wav";




// PROMOTION STUFF
// 4 Buttons in the form of squares, yhe promotion Sq
int to=5; // defualt value is 5 
boolean showChoices = false;

float newQx, newQy, newBx, newBy, newNx, newNy, newRx, newRy;
color highlight = 85;
color buttonC;
boolean hoverQ=false; boolean hoverB=false; boolean hoverN=false; boolean hoverR=false; boolean hovera = false;
boolean Wpromotion = false; boolean Bpromotion= false; 
Piece pPawn=null; // pawn to be promoted
//PImage QI, BI, NI, RI; // the buttton images;
float QIx, QIy, BIx, BIy, NIx, NIy, RIx, RIy; // ..,. and their locations

float  arcx, arcy, arcw, arch;


  
PFont font;
//char X = 'x';


void h_update(int x, int y, int c) {
  if ( overRect(newQx, newQy, n) ) {
    hoverQ = true;
    hoverB = false;
    hoverN = false;
    hoverR = false;
    hovera = false;
  } else if ( overRect(newBx, newBy, n) ) {
    hoverQ = false;
    hoverB = true;
    hoverN = false;
    hoverR = false;
    hovera = false;
  } else if ( overRect(newNx, newNy, n) ) {
    hoverQ = false;
    hoverB = false;
    hoverN = true;
    hoverR = false;
    hovera = false;
  }else if ( overRect(newRx, newRy, n) ) {
    hoverQ = false;
    hoverB = false;
    hoverN = false;
    hoverR = true;
    hovera = false;
  }else if ( overArch(arcx, arcy, arcw, arch, c) ) {
    hoverQ = false;
    hoverB = false;
    hoverN = false;
    hoverR = false;
    hovera = true;
  }else {
    hoverQ = hoverB = hoverN = hoverR = hovera = false;
  }
}

//void mousePressed() {
//  if (circleOver) {
//    currentColor = circleColor;
//  }
//  if (rectOver) {
//    currentColor = rectColor;
//  }
//}

// generic function to have the comp recognize when we howver ovwer a rect(button)
boolean overRect(float x, float y, float N)  {
  if (mouseX >= x && mouseX <= x+N && 
      mouseY >= y && mouseY <= y+N) {
    return true;
  } else {
    return false;
  }
}

boolean overArch(float x, float y, float w, float h, int c)  {
  if(c>0){ // concave up, black promotion
    if (mouseX >= x-w/2 && mouseX <= x+w/2 && 
        mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }else if(c<0){ // concave down
    if (mouseX >= x-w/2 && mouseX <= x+w/2 && 
        mouseY <= y && mouseY >= y-h) {
      return true;
    } else {
      return false;
    }
  
  }else{
    println("concavity problem");
    return false;
  }
}



// MAIN
// implement Window + Board changes
void settings(){
  // to check if font exists
  //String[] fontList = PFont.list();
  //printArray(fontList);
  
  
  // soundcodetest
  //Satie = new SoundFile(this, "245Assign4_AsimiakwiniDaniel.wav"); // codetest
  //Satie.play();
  
  //String path = sketchPath();
  //println("Listing all filenames in a directory: ");
  //String[] filenames = listFileNames(path);
  //printArray(filenames);
  
  //IN-GAME SOUNDS
  move = new SoundFile(this, move_sound); check = new SoundFile(this, check_sound); mate = new SoundFile(this, mate_sound); stale = new SoundFile(this, stale_sound); illegal = new SoundFile(this, no);
  capture = new SoundFile(this, cap_sound);
  
  size(w_width, w_length, P2D);
  
  //int n = (w_width - board_x*2) / grid; // length of 1 square on board
  
  //INITIALIZE PIECES on board
  // PAWNS
  //String pawn = "Pawn2.png";
  //PImage WpawnImage = loadImage(pawn); WpawnImage.resize(3*n/5, 4*n/5);
  
  
  //for(int i=0; i<grid; i++){
  //  WPawns.add(new Pawn(WpawnImage,0,0,white,i));    
  //}
  

  /*
  
  // To make a generic piece; Used a Queen only as a demonstration
  String piece1 = "Queen2.png";
  PImage PieceImage = loadImage(piece1); PieceImage.resize(n+n/3, n+n/10);
  WQueenD = new Piece(PieceImage,PieceX,PieceY,white);
  
  
  
  // Place pieces on the board(Only did 2 actual pieces for demonstrayion)
  ChessBoard.squarePiece(5,4,WQueenD);
  */
  
  
  
  
  // MAIN PIECES
  //their pics
  for(int i=0; i<picstrings.length; i++){
    images.add(picstrings[i]+W+ext);
    images.add(picstrings[i]+B+ext);
  }
  /*
  for(int i=0; i<10; i++){
    println(images.get(i));

  */
  
  //KINGS INIT + SET
  WKingImage = loadImage(images.get(0)); WKingImage.resize(n, n);
  BKingImage = loadImage(images.get(1)); BKingImage.resize(n, n);
  // Add to white and black pieces lists
  WKing = new King(WKingImage, 0, 0, white); BKing = new King(BKingImage, 0, 0, black);
  
  //QUEENS INIT + SET
  WQueenImage = loadImage(images.get(2)); WQueenImage.resize(n+n/3, n+n/10);
  BQueenImage = loadImage(images.get(3)); BQueenImage.resize(n+n/3, n+n/10);
  // Add to white and black pieces lists
  WQueen = new Queen(WQueenImage, 0, 0, white); BQueen = new Queen(BQueenImage, 0, 0, black);
  
  //BISHOPS INIT + SET
  WBishopImage = loadImage(images.get(4)); WBishopImage.resize(n+n/10, n+n/10);
  BBishopImage = loadImage(images.get(5)); BBishopImage.resize(n+n/10, n+n/10);
  // Add to white and black pieces lists
  
  WBishopw = new Bishop(WBishopImage,0,0,white); BBishopw = new Bishop(BBishopImage,0,0,black);
  WBishopb = new Bishop(WBishopImage,0,0,white); BBishopb = new Bishop(BBishopImage,0,0,black);
  
  
  //KNIGHTS INIT + SET
  WKnightImage = loadImage(images.get(6)); WKnightImage.resize(n-15, n);
  BKnightImage = loadImage(images.get(7)); BKnightImage.resize(n-15, n);
  // Add to white and black pieces lists
  WKnight1 = new Knight(WKnightImage,0,0,white); BKnight1 = new Knight(BKnightImage,0,0,black);
  WKnight2 = new Knight(WKnightImage,0,0,white); BKnight2 = new Knight(BKnightImage,0,0,black);
  
  //ROOKS INIT + SET
  WRookImage = loadImage(images.get(8)); WRookImage.resize(n-25, n-15);
  BRookImage = loadImage(images.get(9)); BRookImage.resize(n-25, n-15);
  // Add to white and black pieces lists
  WRook1 = new Rook(WRookImage,0,0,white); BRook1 = new Rook(BRookImage,0,0,black);
  WRook2 = new Rook(WRookImage,0,0,white); BRook2 = new Rook(BRookImage,0,0,black);
  
  
  //PAWNS INIT + SET
  WPawnImage = loadImage(images.get(10)); WPawnImage.resize(n-20, n-20);
  BPawnImage = loadImage(images.get(11)); BPawnImage.resize(n-20, n-20);
  
  // Add to white and black pieces lists
  for(int i=0; i<grid; i++){
    WPawns.add(new Pawn(WPawnImage,0,0,white,i));    
  }
  for(int i=0; i<grid; i++){
    BPawns.add(new Pawn(BPawnImage,0,0,black,i));    
  }
  
  //WHITE PIECES ADDED to Player list 1
  WhitePieces.add(WKing); WhitePieces.add(WQueen); WhitePieces.add(WBishopw); WhitePieces.add(WBishopb); WhitePieces.add(WKnight1); WhitePieces.add(WKnight2); WhitePieces.add(WRook1); WhitePieces.add(WRook2);
  for(int i=0; i<grid; i++){
   WhitePieces.add( WPawns.get(i) );
  }
  
  //BLACK PIECES ADDED to Player list 2
  BlackPieces.add(BKing); BlackPieces.add(BQueen); BlackPieces.add(BBishopw); BlackPieces.add(BBishopb); BlackPieces.add(BKnight1); BlackPieces.add(BKnight2); BlackPieces.add(BRook1); BlackPieces.add(BRook2);
  for(int i=0; i<grid; i++){
   BlackPieces.add( BPawns.get(i) );
  }
  army = WhitePieces.size();
  
  // PLAYERS SET
  p1 = new Player(0, WhitePieces);
  p2 = new Player(1, BlackPieces);
  
  //boolean battle = false;
  // put players pieces on board in right locations
  //KING
  ChessBoard.squarePiece(4,0,WKing); ChessBoard.squarePiece(4,7,BKing);
  
  
  //QUEEN
  ChessBoard.squarePiece(3,0,WQueen); ChessBoard.squarePiece(3,7,BQueen);
  
  
  //BISHOP(S)
  ChessBoard.squarePiece(2,0,WBishopb); ChessBoard.squarePiece(2,7,BBishopw);
  ChessBoard.squarePiece(5,0,WBishopw); ChessBoard.squarePiece(5,7,BBishopb);

  
  //KNIGHTS(S)
  ChessBoard.squarePiece(1,0,WKnight1); ChessBoard.squarePiece(1,7,BKnight1);
  ChessBoard.squarePiece(6,0,WKnight2); ChessBoard.squarePiece(6,7,BKnight2);
  
  //ROOK(S)
  ChessBoard.squarePiece(0,0,WRook1); ChessBoard.squarePiece(0,7,BRook1);
  ChessBoard.squarePiece(7,0,WRook2); ChessBoard.squarePiece(7,7,BRook2);
    
  //PWANS
  for(int i=0; i<grid; i++){
    ChessBoard.squarePiece(i,1,WPawns.get(i));
    ChessBoard.squarePiece(i,6,BPawns.get(i));
  }
  
  
  // READY TO PLAY
  game = new Game(p1,p2,ChessBoard);
  
  

  
  // update moves for all pieces after initialization
  
  ChessBoard.update();
  
  //frameRate(FPS);
}

// what I want the window to show
void draw(){
  background(bg_colour);
  
  ChessBoard.show();
  
  
/*
  // Again, the Black Queen is just an(moveable) Image drawn 
  String p2 = "Queen2b.png";
  PImage Pieceb = loadImage(p2); Pieceb.resize(150,120);
  image(Pieceb,PieceXb,PieceYb);
  */
  // BUTTONS
  int c = 0; // concavity of the exit 'x' arc
  if(showChoices){
    //game.pMenu();
    if(Bpromotion){
      c=1;
    }else if(Wpromotion){
      c=-1;
    }
    h_update(mouseX, mouseY, c);
    
    // Queen button
    if (hoverQ) {
      fill(highlight);
    } else {
      fill(buttonC);
    }
    if(Wpromotion) {
      stroke(0);
    }else if(Bpromotion){
      stroke(255);
    }
    square(newQx, newQy, n);
    if(Wpromotion){
      image(WQueenImage,QIx,QIy);
    }else{
      image(BQueenImage,QIx,QIy);
    }
    
    //Bishop Button
    if (hoverB) {
      fill(highlight);
    } else {
      fill(buttonC);
    }
    if(Wpromotion) {
      stroke(0);
    }else if(Bpromotion){
      stroke(255);
    }
    square(newBx, newBy, n);
    if(Wpromotion){
      image(WBishopImage,BIx,BIy);
    }else{
      image(BBishopImage,BIx,BIy);
    }
    
    //Knight Button4
    if (hoverN) {
      fill(highlight);
    } else {
      fill(buttonC);
    }
    if(Wpromotion) {
      stroke(0);
    }else if(Bpromotion){
      stroke(255);
    }
    square(newNx, newNy, n);
    if(Wpromotion){
      image(WKnightImage,NIx,NIy);
    }else{
      image(BKnightImage,NIx,NIy);
    }
    
    //Rook Button
    if (hoverR) {
      fill(highlight);
    } else {
      fill(buttonC);
    }
    if(Wpromotion) {
      stroke(0);
    }else if(Bpromotion){
      stroke(255);
    }
    square(newRx, newRy, n);
    if(Wpromotion){
      image(WRookImage,RIx,RIy);
    }else{
      image(BRookImage,RIx,RIy);
    }
    
    // the closing arc
    if (hovera) {
      fill(highlight);
    } else {
      fill(buttonC);
    }
    if(Wpromotion) {
      stroke(0);
    }else if(Bpromotion){
      stroke(255);
    }
    //arc
    float txty = arcy;
    if(Bpromotion){
      arc(arcx, arcy, arcw, arch, 0, PI, OPEN);
      txty = arcy+arch/4;
    }else if(Wpromotion){
      arc(arcx, arcy, arcw, arch, PI, 2*PI, OPEN);
      txty = arcy-arch/4;
    }
    fill(0);
    text('x',arcx,txty);
    textAlign(CENTER);
    
    
    
    }
}


// the "dist" between 2 points, arguments are the x,y coords in term of pixels
float euclidean(float [] A, float[] B){  
  float a = A[0] - B[0];  float b = A[1] - B[1];
  return sq(a)+sq(b);
}

void mousePressed(){
  
  Piece next;
  
  for(int p=0; p<WhitePieces.size(); p++){
    next = WhitePieces.get(p);
    if(next.active()){  next.select(mouseX,mouseY);  }
  }
  for(int p=0; p<BlackPieces.size(); p++){
    next = BlackPieces.get(p);
    if(next.active()){  next.select(mouseX,mouseY);  }
  }
  
  // Promotion Buttons
  if (hoverQ) { // to a Queen
    game.wasPromoted(true);
    showChoices=false; 
    
    to=0; game.promote(to);
    
  }else if (hoverB) { // to a Bishop
    game.wasPromoted(true);
    showChoices=false;
    
    to=1; game.promote(to);
    
  }else if (hoverN) { // to a Knight
    game.wasPromoted(true);
    showChoices=false;
    
    to=2; game.promote(to);
    
  }else if (hoverR) { // to a Rook
    game.wasPromoted(true);
    showChoices=false;
    
    to=3; game.promote(to);
    
    
  }else if (hovera) { // cancel promotion
    game.wasPromoted(false);
    showChoices=false;
    
    to=4; game.promote(to);
  }

  
  
}

/*
float[] Bishopfinal_pos; 
//float[] movedFinal_pos;
ArrayList<float[]> Pawnfinal_poses = new ArrayList<float[]>(); // rows x cols = 8 x 2
*/
//float[] Queenfinal_pos; 

// rows x cols = 16 x 2 for both = army x 2
ArrayList<float[]> WPieces_Finalposes = new ArrayList<float[]>();
ArrayList<float[]> BPieces_Finalposes = new ArrayList<float[]>();
void mouseDragged(){
  Piece next;
  //Queenfinal_pos = WQueenD.movement();
  // allow free motion for pieces
  /*
  Bishopfinal_pos = BBishop.movement();
  
  for(int i=0; i<grid; i++){
    Pawnfinal_poses.add(WPawns.get(i).movement());   // palce on 7th rank
  }
  */
  WPieces_Finalposes.clear(); BPieces_Finalposes.clear(); // all pieces(even inactive[captured] will get the movement method. But only the active will be put on a square)
  
  
  for(int p=0; p<WhitePieces.size(); p++){
    next = WhitePieces.get(p);
    WPieces_Finalposes.add(WhitePieces.get(p).movement());  
  }
  for(int p=0; p<BlackPieces.size(); p++){
    next = BlackPieces.get(p);
    BPieces_Finalposes.add(BlackPieces.get(p).movement());  
    //if(next.getClass()==Bishop.class && p==15) println(BlackPieces.get(p).movement()[0],BPieces_Finalposes.get(p)[0]); //println(next.active(),next.IsSelected());
  }
  
  /*
  // for black queen frre movement
  if((PieceXb-75)<mouseX && mouseX<(PieceXb+75)   &&   (PieceYb-60)<mouseY && mouseY<(PieceYb+60) ){
    PieceXb = mouseX; PieceYb = mouseY;
  }
  */
  
}


void mouseReleased(){
  Piece next;
  // make sure piece "snaps" to actual viable Sq(square), // compare final pos with all square centres and place piec on closeset euclid centre
  
  /*
  if(piece_selected){
    println("released");
    ChessBoard.OnSquare(movedFinal_pos, moved);
  }
  */
  //ChessBoard.OnSquare(Queenfinal_pos,WQueenD);

  /*
  for(int i=0; i<grid; i++){
    //println(i," = ",Pawnfinal_poses.get(i)[0],Pawnfinal_poses.get(i)[1]);
    ChessBoard.OnSquare( Pawnfinal_poses.get(i), WPawns.get(i) );   // Makes sure all pawns are on a square
  }
  */
  // FOR SETTING ON SQUARE
  if(WPieces_Finalposes.size()!=0) // to prevent null error on first click
  
  for(int p=0; p<WhitePieces.size(); p++){
    next = WhitePieces.get(p);
    if(next.active()){ ChessBoard.OnSquare( WPieces_Finalposes.get(p), WhitePieces.get(p) ); }
  }

  
  if(BPieces_Finalposes.size()!=0)
  
  //println(BPieces_Finalposes.size(),BlackPieces.size());
  for(int p=0; p<BlackPieces.size(); p++){
    next = BlackPieces.get(p);
    //if(next.getClass()==Bishop.class && p==16) println(BPieces_Finalposes.get(p));
    if(next.active()){ ChessBoard.OnSquare( BPieces_Finalposes.get(p), BlackPieces.get(p) ); }
  }

  
  
  
  //FOR SELECTING ONLY ONE PIECE TO MOVE
  //Player[] Players = game.getPlayers();

  for(int p=0; p<WhitePieces.size(); p++){
    next = WhitePieces.get(p);
    if(next.active()){ WhitePieces.get(p).setSelect(false); }
  }
  for(int p=0; p<BlackPieces.size(); p++){
    next = BlackPieces.get(p);
    if(next.active()){ BlackPieces.get(p).setSelect(false); }
  }
  
  //println(ChessBoard.squares[0][1].getPiece().getClass().getName());
  
  // UPDATE ALL PIECES POSITION ON BAORD
  
  if(game.getMoves()==game.getReg().size()){ // only update if need to(a move was actually made)
    ChessBoard.update();
  }else{
    game.reset_moves(); // reset->moves = reg.size() so that we are back on track
  }
  
  //println(Bpromotion);
  if(p1.inCheck()){
    println("whKing has",p1.getPieces().get(0).getMoves().size()-1);
  }else if(p2.inCheck()){
    println("blaKing has",p2.getPieces().get(0).getMoves().size()-1);
  }
  println("Register: ", "move attempts:",game.getMoves(), "actual moves:",game.getReg().size());
  println("");
  
  // sound check
  if(p1.inCheck()||p2.inCheck()){
    check.play();
    
  }else if(true){
    
  }
  
  
  
  /*
  ArrayList<Piece>R = game.getReg();
  int n = R.size();
  for(int i=0; i<n; i++){
    println(i,R.get(i).getClass(),"colour =",R.get(i).getC());
  }
   */ 
   
 Bpromotion = game.getPromotionB(); Wpromotion = game.getPromotionW();
 
 if(Wpromotion || Bpromotion){
   font = createFont("Onyx",20);
   // set pawn to be promoted
   pPawn = game.promoted();
   
   

   // set button locations
   ArrayList<float[]>bl = game.pButtonsLoc();
   float Ql[] = bl.get(0); float Bl[] = bl.get(1); float Nl[] = bl.get(2); float Rl[] = bl.get(3); float a[] = tl_to_centre(bl.get(4),n);
   
   // button square locs
   newQx=Ql[0]; newQy=Ql[1];
   newBx=Bl[0]; newBy=Bl[1];
   newNx=Nl[0]; newNy=Nl[1];
   newRx=Rl[0]; newRy=Rl[1];
   
   arcx = a[0]; arcw = n; arch = n/3;
   if(Bpromotion){
     arcy = a[1]-n/2; // x a little up
   }else if(Wpromotion){
     arcy = a[1]+n/2; // x a little down
   } 
   
   // button image locs
   float QlI[] = tl_to_centre(Ql,n); float BlI[] = tl_to_centre(Bl,n); float NlI[] = tl_to_centre(Nl,n); float RlI[] = tl_to_centre(Rl,n);
   
   QIx=QlI[0]; QIy=QlI[1];
   BIx=BlI[0]; BIy=BlI[1];
   NIx=NlI[0]; NIy=NlI[1];
   RIx=RlI[0]; RIy=RlI[1];
   
   
   //set button colours
   buttonC = game.pButtonColor();
   
   if(pPawn!=null && overRect(newQx, newQy, n)){
     showChoices=true;
   }
 }
 
}
