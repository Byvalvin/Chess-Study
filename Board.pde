// BOARD OBJECT

class Board{
  float grid_size = 8; float sq_n; // 8x8 board, each square has length sq_n
  
  // board corner(top left) coord + length
  float bx; float by; 
  float b_length;
  
  // colours, for checkered board
  int light = 200; int dark = 50;
  int curr_col = dark;
  
  // A board is made of squares, here are the squares, in matrix form
  Sq[][] squares = new Sq[int(grid_size)][int(grid_size)];
  
  //int wstarts = 8; int bstarts = wstarts;
  
  Board(float x, float width_){ // just need the x coordinate(top left) for the board and window lenth to make the board
    
    // decrease bx for bigger boards
    bx = x; by = bx;
    b_length = width_-(bx*2);
    
    // checkered
    sq_n = b_length/grid_size;
    
    // here, a board is a matrix of squares with a bunch of extra methods
    make_squares();
  }
  
  // the squares of the board, filled
  void make_squares(){
    for(int yi=0; yi<int(grid_size); yi++){ //y: squares have coordinates for BOTH their pixelized location on board and their matrix/ation location on board
      float y_coor = by + sq_n*yi; // pixel y coord of square
      
      // reset flips(for colour of square)
      if(curr_col == dark){
          curr_col = light;
        }else{
          curr_col = dark;
        }
        
      for(int xi=0; xi<int(grid_size); xi++){ //x
        float x_coor = bx + sq_n*xi; // pixel x coord of square
        
        // colour of square
        if(curr_col == dark){
          curr_col = light;
        }else{
          curr_col = dark;
        }
        
        // make square and add it to board using matrix coordinate
        Sq a_square = new Sq(x_coor, y_coor, sq_n, curr_col,xi,yi);
        squares[xi][yi] = a_square;
         
      }
      
    }

  }
  

  // places a Piece piece on a square at (i,j), matrix coord
  void squarePiece(int i, int j, Piece piece){
    squares[i][j].setPiece(piece);
  }
  
  // displays all of board
  void show(){  
    
    // first, show squares
    for(int i=0; i<int(grid_size); i++){ // x
      for(int j=0; j<int(grid_size); j++){ // y
        squares[i][j].show();
      }
    }
   
     // SHPW PIECES ONLY AFTER SHOWING SQUARES
    for(int i=0; i<int(grid_size); i++){ //x
      for(int j=0; j<int(grid_size); j++){ //y
        squares[i][j].showPiece();
      }
      
    }
    
  }
  
  // disnt use but could use if needed, updates square at (i,j) matrix coord to say it no longer has a piece on it
  void moved(int i, int j){
    squares[i][j].movedPiece();
  }

  // keeps pieces on proper squares/prevents "floating" pieces
  void OnSquare(float[] current, Piece P){
    // takes the current pixel location of the piece P and finds the closest Sq
    if(P.IsSelected()){
      float shortest = 1000000; 
      int chosen_x = 0; int chosen_y = 0;
      
      float next;
    
      for(int j=0; j<int(grid_size); j++){
        for(int i=0; i<int(grid_size); i++){
          
          next = euclidean(squares[i][j].get_cent_coord(),current);
          if( next < shortest ){
            shortest = next;
            chosen_x = i; chosen_y = j;
          }
          
        }  
      }

      
      // chosen cant be current
      Sq currSq = P.getCurrSq();
      Sq chosen = squares[chosen_x][chosen_y];
      int[] stay_matrix_loc = currSq.get_matrix_loc();
      
      int attackC = P.getC();
      // CHECKS, and moure
      
      Player currP = game.getPlayer(attackC);
      //Player[] Players = game.getPlayers();//Players[0]; Player otherP = Players[1];

        
      boolean allowed = P.getMoves().contains(chosen) && chosen!=currSq;
       
      boolean capped = false; // to know if something is captured, also helps sound
      boolean enPassed = false; // enPass captures, helps sound
      
      boolean forward = false; boolean back = false;
      boolean pinned = forward && back; // solely for sound
      
      boolean cant = false; // soley for sound
      
      boolean no_castle = false; // again sound
      boolean try_castle = false;
      
      boolean mated = false; // for sound and to end game
      boolean staled = false;
      
      // PROMOTION
      boolean tried_promotion = false; boolean promoted = false;
      boolean On_promotionSqW = P.getClass()==Pawn.class && chosen_y==7 && attackC!=0; //WHITE PAWN goes down board(y=1->7)
      boolean On_promotionSqB = P.getClass()==Pawn.class && chosen_y==0 && attackC==0; //BLACK PAWN goes up board(y=6->0)
      
      boolean On_promotionSq = false; // so we only need to refer to one promotion var
      if(On_promotionSqW && !On_promotionSqB){
        On_promotionSq = On_promotionSqW;
      }else if(On_promotionSqW && !On_promotionSqB){
        On_promotionSq = On_promotionSqB;
      }
      
      
    
         
      // CHECK IF CASTLING
      boolean x_diff_is_2 = abs(stay_matrix_loc[0]-chosen_x) == 2;
      boolean same_y = stay_matrix_loc[1] == chosen_y;
      if( P.getClass()==King.class && x_diff_is_2 && same_y && !currP.hasCastled() ){ // player wants to castle
        try_castle = true;
        int [] castle_dir = {chosen_x,chosen_y};
          if(game.player_canCastle(currP, castle_dir)){
            currP.castle(this,castle_dir);
            println("CASTLED!"); 
            
            // CASTLE SOUND
            // sound
            move.play();
            delay(100);
            move.play();
            
            
            
            game.updateReg(P);
          }else{ // stay
            squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P);
            
            no_castle = true;
          }
       
       
      // NOT CASTLING->REGULAR(most) moves
      }else{
      
        // If NOT Castling
        
        if( (shortest != 0 && allowed) ){
          // clear all previous offerings
          game.clearEnPass();
          
          
          // ENPASSANT OFFERING
          if(P.getClass()==Pawn.class && !P.moved() && abs(chosen_y - stay_matrix_loc[1])==2){
            P.set_jump(true);
          }
          
 
          currSq.movedPiece(); // piece is mooving fosho, 3 ways[with EnPassant Cap, with Reg Cap, Empty Square/ with no Cap]
          
          println("moved",P.getClass().getName(),attackC);
          
          // FIRST -> CAPTURES and blocks(own piece)
          //capped = false;
          
          // ENPASSANT CAPTURES 
          
          boolean enPassL = game.can_EnPassantLeft(P,attackC);
          boolean enPassR = game.can_EnPassantRight(P,attackC);
          boolean move_forward = chosen_x==stay_matrix_loc[0];
          if(  P.getClass()==Pawn.class && (enPassL || enPassR) && !move_forward){
            println("enpass"); 
            enPassed = true;
            
            if(enPassL && enPassR){
              if(P.getfirstEPSn()==0){//left was first, so it is lost
                // to the right
                //println("lost left");
                game.EnPassantCapRight(P,attackC);
                squarePiece(chosen_x, chosen_y,P); forward = true;
                
                game.updateReg(P);
              }else{
                // to the left
                //println("lost right");
                game.EnPassantCapLeft(P,attackC);
                squarePiece(chosen_x, chosen_y,P); forward = true;
                //P.set_EnPassantLeft(false);
                
                game.updateReg(P);
              }
              
              
            }else{
              if(enPassL){ // to the left
                game.EnPassantCapLeft(P,attackC); capped=true;
                squarePiece(chosen_x, chosen_y,P); forward = true;
                //P.set_EnPassantLeft(false);

                
                game.updateReg(P);
                
              }else if(enPassR){ // to the right
                game.EnPassantCapRight(P,attackC); capped=true;
                squarePiece(chosen_x, chosen_y,P); forward = true;
                
                game.updateReg(P);
                //P.set_EnPassantLeft(false);
              }
              
              
            }
              
            //}else{// WONT RUN IF CANT DO EITHER
            //  squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P);
            //}
          
          }
          
          // A PIECE IN THE PATH, Regular CAPTURES
          else if(chosen.hasPiece()){
            
            Piece attacked = chosen.getPiece();
            
            if(!game.sameC(attacked,P)){
              //println(attacked.getClass(),King.class);
              
              if(On_promotionSqW || On_promotionSqB){
                // for promotions
                
                //set promotion vars
                game.setPromotionW(On_promotionSqW); game.setPromotionB(On_promotionSqB); // Should only be one at a time, too lazy to determine which
                game.setPromoted(P);
                game.setPromotionSq(chosen);
                
                //capped = true;
                
                // game.promote will handel captures
              
              
              //regular
              }else{
                if(attacked.getClass() != King.class){
 
                  game.cap(attacked, chosen);
                  capped = true;
                  squarePiece(chosen_x, chosen_y,P); forward = true;
                  
                  game.updateReg(P);
                 
                }else if(attacked.getClass()==King.class){
                  squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P);
                }
              }
              
            }else{
              squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P); // cant attack yout owm piece
              forward = true;
            }
            
          // REGULAR MOVE TO AN EMPTY SQUARE
          }else{
            
            if(On_promotionSqW || On_promotionSqB){
              // for promotions
              
              game.setPromotionW(On_promotionSqW); game.setPromotionB(On_promotionSqB); // Should only be one at a time, too lazy to determine which
              game.setPromoted(P);
              game.setPromotionSq(chosen);
              
              // regular
            }else{
              game.updateReg(P);
              squarePiece(chosen_x, chosen_y,P); forward = true;
            }
            

          }
          
          //game.updateReg(P);
          
          // PART 2
          // FOR PINS(MANDATORY CANT MOVES) AND CHECKS(MANDATORY MOVES)-> the moves are allowed under reg conds but 
          
          //boolean chosen_is_not_stay = chosen_x!=stay_matrix_loc[0] && chosen_y!=stay_matrix_loc[1];// chosen loc isnt the same as the current loc(only to solve the enpassant problem)

          update(); // only update if need to(a move was actually made)
          
          
          
        }
        // ILLEGAL MOVE, piece didnt and wont move
        else if(!allowed){
          //println("NOTmoved",P.getClass().getName());
          if(P.IsSelected() && !(chosen==currSq)){
            cant = true;
          }
          squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P); 
        }
      
  
      
  

        
        
        // checking checks
        Player otherP = null;
        if(attackC==0){
          otherP = game.getPlayer(1); // P1
        }else{
          otherP = game.getPlayer(0); // P2
        }
        
        if(currP.inCheck()){ // if after update, king in check, then 1) cant make that move revert to 0G pos 2) revert back any pawn first moves 3)Reveert captures 4)Place back on OG square
          Sq newCurrSq = P.getCurrSq();
          newCurrSq.movedPiece(); //1)
          
          if(P.getClass()==Pawn.class && P.startSq(stay_matrix_loc[0], stay_matrix_loc[1]) ){ // if it is a pawn that wsa improperly moved, let it have its first move buff again but only if it is reverted back to its START square
            P.first_again(); // 2)
          }
          
          if(capped){
            game.revcap(P, newCurrSq, enPassed); //3)
            capped=false;
          }
          
          squarePiece(stay_matrix_loc[0], stay_matrix_loc[1],P); // 4) 
          back=true;
          update();
          
          

        }else if(otherP.inCheck()){
          update();
          
          if(otherP.inCheck() && P.IsSelected()){// still in check
            // get attackers
            ArrayList<Piece> KingAttackers = game.offensive(currP);
            mated = game.checkmate(otherP, KingAttackers);
          }
          
        }
        
      }
      
      // do this every move
      if(P.IsSelected()){// dont want all 32
        //println(P.counts());
        //for(int i=0; i<16; i++){
        //  println(currP.getPieces().get(i).getClass());
        //}
        game.upMoves();
        staled = game.stalemate(currP);
      }
      
      // sounds play
      
      // ILLEGAL MOVE SOUND
      pinned = forward && back;
      if((pinned || (try_castle && no_castle) || cant) && P.IsSelected()){
        illegal.play();
      }
      
      // CAPTURE SOUND
      if(capped){
        //sound cap
        capture.play();
        
        // check if insufficient material to continue(only when a piece is captureed)
        game.I_M();
      }
      
      // MOVE SOUND
      if((!capped && !currP.inCheck() && !pinned && !cant && !(try_castle && no_castle)) && P.IsSelected()){
        move.play();
       }
       
       // FOR MARK
       // for this, youll only need to know how soundfiles work. I'll put a link in discord
       
       //Like the previous sounds, I want you to write the code for checkmate and stalemate sounds. Follow the prev sounds as examples-> Consider using the boolean vars("mated" and "staled")
       // [They should be at the very top of this method]
       
       // Some guidelines
       //STEP 1) Determine what sound to use for checkmate and stalemate respectively. Completely up to you. You can find em online or make em yourself
       //STEP 2) Make sure the sounds are either .wav/.mp3 others may work or may crash...
       //STEP 3) Make sure the chosen sounds are actually in the "sketch folder" -> this one may be a bit tricky so lemme know
       //STEP 4) Check "Chess1" code and see the SoundFile vars for checkmate and stalemate
       //STEP 5) Edit the vars so they use the chosen sounds for checkmate and stalemate respectively
       //STEP 6) Use the SoundFile vars here, play them when mate is true/ stale is true(similar to oabove scenarios)
       
       // I made these as guiding steps, not rules. Do whatever you feel works. The goals here are;
       // A) Once a player is mated, the sound for checkmate plays
       // B) Once there is a stalemate, the sound for stalemate plays
       
       // You dont have to worry about -how- these happen in code or otherwise, just try and get the sounds to work with the gameplay
       // If you have questions...
       
       
       // CODE FOR CHECKMATE SOUND
       
       
       //CODE FOR STALEMATE SOUND
      
      
      
  }
  
  }
  
  // return square at (i,j) matrix coord on board
  Sq getSquare(int i, int j){
    return squares[i][j];
  }
  
  Sq[][] getSquares(){
    return squares;
  }
  
  // update all pieces possible moves
  void update(){
    
    for(int yi=0; yi < int(grid_size); yi++){ //y
      for(int xi=0; xi < int(grid_size); xi++){ //x
        
        if(squares[xi][yi].hasPiece()){ // only updates if the square has a piece on it
          squares[xi][yi].updatePieceMoves(squares);
        }
        
        
      }
    }
    game.checks();
    
    
  }
  
  // return the piece on the square that the mouse is currently on
  Sq mouse(float x, float y){
    
    // eucldean again; check all, the smallest of all dists is the square
    float[] mouse_loc = {x,y};
    
    float shortest = 100000; 
    int shortest_x = 4;  int shortest_y  = 3; // rando inits because Java dumb
    
    for(int yi=0; yi < int(grid_size); yi++){ //y
      float check_short;
      for(int xi=0; xi < int(grid_size); xi++){ //x
        check_short = euclidean(mouse_loc, squares[xi][yi].get_cent_coord());
        if(check_short<shortest){
          shortest = check_short;
          shortest_x = xi; shortest_y = yi;
        }
        
      }
    }
    
    
    
    return squares[shortest_x][shortest_y];
    
  }
  
  
  ArrayList<Sq> nearBySquares(int x, int y){ // all the squares touching a square-> at least 3 mmost 8
    ArrayList<Sq> near = new ArrayList<Sq>();
    
    int tl_x = x-1; int tl_y = y-1;                     int t_y = y-1;               int tr_x = x+1; int tr_y = y-1;
    int l_x = x-1;                                                                   int r_x = x+1;   
    int bl_x = x-1; int bl_y = y+1;                     int b_y = y+1;               int br_x = x+1; int br_y = y+1;
    
    if( (0<=tl_x && tl_x < int(grid_size)) && (0<=tl_y && tl_y < int(grid_size)) ){
      near.add(squares[tl_x][tl_y]);
    }
    if( (0<=l_x && l_x < int(grid_size)) && (0<=y && y < int(grid_size)) ){
      near.add(squares[l_x][y]);
    }
    if( (0<=bl_x && bl_x < int(grid_size)) && (0<=bl_y && bl_y < int(grid_size)) ){
      near.add(squares[bl_x][bl_y]);
    }
    if( (0<=x && x< int(grid_size)) && (0<=t_y && t_y < int(grid_size)) ){
      near.add(squares[x][t_y]);
    }
    if( (0<=x && x< int(grid_size)) && (0<=b_y && b_y < int(grid_size)) ){
      near.add(squares[x][b_y]);
    }
    if( (0<=tr_x && tr_x< int(grid_size)) && (0<=tr_y && tr_y < int(grid_size)) ){
      near.add(squares[tr_x][tr_y]);
    }
    if( (0<=r_x && r_x< int(grid_size)) && (0<=y && y < int(grid_size)) ){
      near.add(squares[r_x][y]);
    }
    if( (0<=br_x && br_x< int(grid_size)) && (0<=br_y && br_y < int(grid_size)) ){
      near.add(squares[br_x][br_y]);
    }
    return near;
    
  }
  
  int size(){
    return int(grid_size);
  }
  
  

  
  
  
}
