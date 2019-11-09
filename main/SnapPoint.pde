class SnapPoint {
  
  private final int PROPER_PIECE_ID;
  private final int X,Y;
  private PuzzlePiece currPiece;
  
  SnapPoint(PuzzlePiece properPiece){
    this.X = properPiece.getX();
    this.Y = properPiece.getY();
    PROPER_PIECE_ID = properPiece.getID();
    currPiece = properPiece;
  }
  
  public boolean isOccupied(){
    return currPiece != null;
  }
  
  public boolean isCorrect() {
    if (currPiece == null)
      return false;
    return PROPER_PIECE_ID == currPiece.getID();
  }
  
  public void setCurrPiece(PuzzlePiece pp){
    currPiece = pp;
  }
  
  public PuzzlePiece getCurrPiece(){
    return currPiece;
  }
  
  public int getX() {
    return X;
  }
  
  public int getY() {
    return Y;
  }
  
}
