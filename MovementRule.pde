import java.util.LinkedList;
import java.util.Collections;

interface MovementRule {
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle);
}

class SugarSeekingMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public SugarSeekingMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    for (Square s : neighborhood) {
      if (s.getSugar() > retval.getSugar() ||
          (s.getSugar() == retval.getSugar() && 
           g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle)
          )
         ) {
        retval = s;
      } 
    }
    return retval;
  }
}

class PollutionMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public PollutionMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    boolean bestSquareHasNoPollution = (retval.getPollution() == 0);
    for (Square s : neighborhood) {
      boolean newSquareCloser = (g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle));
      if (s.getPollution() == 0) {
        if (!bestSquareHasNoPollution || s.getSugar() > retval.getSugar() ||
            (s.getSugar() == retval.getSugar() && newSquareCloser)
           ) {
          retval = s;
        }
      }
      else if (!bestSquareHasNoPollution) { 
        float newRatio = s.getSugar()*1.0/s.getPollution();
        float curRatio = retval.getSugar()*1.0/retval.getPollution();
        if (newRatio > curRatio || (newRatio == curRatio && newSquareCloser)) {
          retval = s;
        }
      }
    }
    return retval;
  }
}

class CombatMovementRule extends SugarSeekingMovementRule {
  int alpha;
  public CombatMovementRule(int alpha) {
    CombatMovementRule cm = new CombatMovementRule(alpha); 
    this.alpha = alpha;
  }
  
  public int getAlpha() {
    return alpha;
  }
  
  public Square move(LinkedList<Square> neighbourhood, SugarGrid g, Square middle) {
    for (int i=0;i<neighbourhood.size();i++) {
      if (neighbourhood.get(i).getAgent().getTribe() == middle.getAgent().getTribe()) {
        neighbourhood.remove(i);
      }
    }
    for (int j=0;j<neighbourhood.size();j++) {
      if (neighbourhood.get(j).getAgent().getSugarLevel() >= middle.getAgent().getSugarLevel()) {
        neighbourhood.remove(j);
      }
    }
    LinkedList<Square> vision = new LinkedList<Square>();
    for (int l=0;l<neighbourhood.size();l++) {
      if (neighbourhood.get(l).getAgent() != null) {
        vision = g.generateVision(neighbourhood.get(l).getX(),neighbourhood.get(l).getY(), middle.getAgent().getVision());
      }
      if (vision.get(l).getAgent().getSugarLevel() >= middle.getAgent().getSugarLevel() && vision.get(l).getAgent().getTribe() != middle.getAgent().getTribe()) {
        neighbourhood.remove(l);
      }
    }
    for (int m=0;m<neighbourhood.size();m++) {
      neighbourhood.set(m, new Square(neighbourhood.get(m).getSugar() + this.getAlpha() + neighbourhood.get(m).getAgent().getSugarLevel(), neighbourhood.get(m).getMaxSugar()+ this.getAlpha() + neighbourhood.get(m).getAgent().getSugarLevel(), neighbourhood.get(m).getX(), neighbourhood.get(m).getY()));
    }
    Square target = super.move(neighbourhood,g,middle);
    if (target.getAgent() == null) {
      return target;
    }
    else {
      Agent casualty = target.getAgent();
      target.setAgent(null);
      middle.setSugar(middle.getSugar() + casualty.getSugarLevel() + alpha);
      middle.getAgent().eat();
      g.killAgent(casualty);
      return target;
    }
  }
}

class SugarSeekingMovementRuleTester {
  public void test() {
    SugarSeekingMovementRule mr = new SugarSeekingMovementRule();
    //stubbed
  }
}

class PollutionMovementRuleTester {
  public void test() {
    PollutionMovementRule mr = new PollutionMovementRule();
    //stubbed
  }
}
