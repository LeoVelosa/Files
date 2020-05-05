import java.util.HashMap;
import java.util.Random;
import java.util.Map;
class FertilityRule {
  private Map<Character,Integer[]> childbearingOnset;
  private Map<Character,Integer[]> climactericOnset;
  public Random rand;
  private int c;
  private int o;
  private LinkedList usedAgents;
  public Map<Agent,LinkedList> agentFertility;
  public Map<Agent,Integer> agentSugar;
  
  public FertilityRule(Map<Character,Integer[]> childbearingOnset, Map<Character,Integer[]> climactericOnset) {
    this.childbearingOnset = childbearingOnset;
    this.climactericOnset = climactericOnset;
    
  }
  
  public boolean isFertile(Agent a) {
    if (a == null || !a.isAlive()) {
      return false;
    }
    else {
      if (usedAgents.contains(a) == false) {
        if (a.getSex() == 'X') {
          c = (int)random(childbearingOnset.get('X')[0],childbearingOnset.get('X')[1]);
          o = (int)random(climactericOnset.get('X')[0],climactericOnset.get('X')[1]);
        }
        else{
          c = (int)random(childbearingOnset.get('Y')[0],childbearingOnset.get('Y')[1]);
          o = (int)random(climactericOnset.get('Y')[0],climactericOnset.get('Y')[1]);
        }
        LinkedList temp = new LinkedList();
        temp.add(c);
        temp.add(o);
        agentFertility.put(a,temp);
        agentSugar.put(a, a.getSugarLevel());
        usedAgents.add(a);
      }
    }
    if (a.getAge() < o && a.getAge() >= c && a.getSugarLevel() >= agentSugar.get(a)) {
      return true;
    }
    else {return false;}
  }
  
  public boolean canBreed(Agent a, Agent b, LinkedList<Square> local) {
    if (isFertile(a) == true && isFertile(b) == true && a.getSex() != b.getSex() && local.contains(b.getSquare())) {
      return true;
    }
    else return false;
  }
  
  public Agent breed(Agent a, Agent b, LinkedList<Square> aLocal, LinkedList<Square> bLocal) {
    if (!canBreed(a,b,aLocal) || !canBreed(a,b,bLocal)) {
      return null;
    }
    else {
      int meta = (int)random(a.getMetabolism(),b.getMetabolism());
      int vision = (int)random(a.getVision(),b.getVision());
      MovementRule m = a.getMovementRule();
      char sex = (char)random(a.getSex(),b.getSex());
      Agent child = new Agent(meta,vision,0,m,sex);
      a.gift(child,a.getSugarLevel()/2);
      b.gift(child,b.getSugarLevel()/2);
      child.nurture(a,b);
      LinkedList<Square> squares = new LinkedList();
      Square s;
      for (int i =0;i<aLocal.size();i++) {
        if (aLocal.get(i).getAgent() == null) {
          squares.add(aLocal.get(i));
        }
      }
      for (int i =0;i<bLocal.size();i++) {
        if (bLocal.get(i).getAgent() == null) {
          squares.add(bLocal.get(i));
        }
      }
      s = squares.get((int)random(squares.size()));
      s.setAgent(child);
      return child;
    }
  }
}
