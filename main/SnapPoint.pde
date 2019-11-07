class SnapPoint {
  
  private final int CORRECT_PIECE_ID;
  private final int x,y;
  private int currPieceID;
  
  SnapPoint(int x, int y, int properPieceID, int currPieceID){
    this.x = x;
    this.y = y;
    this.currPieceID = currPieceID;
    CORRECT_PIECE_ID = properPieceID;
  }
  
  public boolean isOccupied(){
    return currPieceID != -1;
  }
  
  public boolean isCorrect() {
    return CORRECT_PIECE_ID == currPieceID;
  }
  
  public void setCurrPiece(PuzzlePiece pp){
    if (pp == null)
      currPieceID = -1;
    else
      currPieceID = pp.getID();
  }
  
  public int getCurrPieceID(){
    return currPieceID;
  }
  
  public int getX() {
    return x;
  }
  
  public int getY() {
    return y;
  }
  
}
