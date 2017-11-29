package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;


public class ProcessSPAMOutput_twelveLBL {

	 static Map<Integer,ArrayList<Integer>> map = new HashMap<Integer,ArrayList<Integer>>();
	 static Map<String,Integer> labelMap = new HashMap<String,Integer>();
	 static Map<String,String> readableLBLMap = new HashMap<String,String>();

	 public static void main(String[] args) {

		 	readableLBLMap.put("a", "(ii)"); readableLBLMap.put("A", "(II)"); 
		 	readableLBLMap.put("b", "(id)"); readableLBLMap.put("B", "(ID)");
		 	readableLBLMap.put("c", "(is)"); readableLBLMap.put("C", "(IS)");

		 	readableLBLMap.put("d", "(si)"); readableLBLMap.put("D", "(SI)");
		 	readableLBLMap.put("e", "(sd)"); readableLBLMap.put("E", "(SD)");
		 	readableLBLMap.put("f", "(ss)"); readableLBLMap.put("F", "(SS)");

		 	readableLBLMap.put("g", "(di)"); readableLBLMap.put("G", "(DI)");
		 	readableLBLMap.put("h", "(dd)"); readableLBLMap.put("H", "(DD)");
		 	readableLBLMap.put("i", "(ds)"); readableLBLMap.put("I", "(DS)");

		 	readableLBLMap.put("j", "(zi)"); readableLBLMap.put("J", "(ZI)");
		 	readableLBLMap.put("k", "(zd)"); readableLBLMap.put("K", "(ZD)");
		 	readableLBLMap.put("l", "(zs)"); readableLBLMap.put("L", "(ZS)");

		 	readableLBLMap.put("_", "_");

		 	
		    String[] listLbl = new String[]{"_","a","b","c","d","e","f",
		    								"g","h","i","j","k","l"};
			int count = 0;
			for (String s: listLbl)
			{
				labelMap.put(s, ++count);
		    	if (s.equals("_") == false)
		    		labelMap.put(s.toUpperCase(), ++count);
	
			}

			BufferedReader reader = null;
			 
			String fname = args[0];//TODO This is the full path to the file
			String oname = args[1];
			long totalCases = Long.parseLong(args[2]);
			File input = new File(fname);
			File output = new File(oname);
			try {
				reader = new BufferedReader(new FileReader(input));
				String line = null;
				String[] clmn;
				String cvsSplitBy = " ";//TODO very important, check input format
				ArrayList<Integer> list;
				int row = 0;
				while ((line = reader.readLine()) != null) {
					row++;
					//sample line format: 8 -1 8 -1 7 -1 8 -1 8 -1 #SUP: 1966
					line = line.replaceAll("#SUP: ", "");
					clmn = line.split(cvsSplitBy); //split is space character
					list = new ArrayList<Integer>();
					for (int i = 0; i < clmn.length; i++)
						list.add(Integer.parseInt(clmn[i]));
					map.put(row,list); //key is the row id
				}
				//sort the data based on the SUP#
				Map<Integer,ArrayList<Integer>> tmp = new HashMap<Integer,ArrayList<Integer>>();
				ValueComparatorData vc = new ValueComparatorData(tmp);
				TreeMap<Integer,ArrayList<Integer>>  sortedTreeMap = new TreeMap<Integer,ArrayList<Integer>>(vc);
				tmp.putAll(map);
				sortedTreeMap.putAll(tmp);

				
				//print output from the most to least frequent pattern, replace numbers by laels
				PrintWriter pw = new PrintWriter(output);
				String txt,txt2;
				double percentage;
				DecimalFormat df = new DecimalFormat("#.##");
				for (ArrayList<Integer> l :sortedTreeMap.values())
				{
					txt = ""; txt2 = "";
					for (int i = 0 ; i < l.size()-1; i++)
					{
						if (l.get(i) != -1)//-1 is the separater character 
						{
							txt += getReadableLbl(getLabel(l.get(i)));
							txt2 += getLabel(l.get(i));
						}
					}
					percentage = (double)(l.get(l.size()-1)*100)/totalCases;
					txt += ("\t"+txt2+"\t #cases: "+ l.get(l.size()-1))+" out of "+ totalCases+" ("+df.format(percentage)+"%)";
					pw.println(txt);
				}
				pw.close();
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				try {
					if (reader != null) {
						reader.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

		}
	 
	 private static String getReadableLbl(String label) {
		return readableLBLMap.get(label);
	}

	private static String getLabel(Integer i) {
		for (String s : labelMap.keySet())
			if (labelMap.get(s) == i)
				return s;
		return null;
	}

	private static class ValueComparatorData implements Comparator<Integer> {

		    Map<Integer,ArrayList<Integer>> base;
		    public ValueComparatorData(Map<Integer,ArrayList<Integer>> base) {
		        this.base = base;
		    }

		    // Note: this comparator sorts the values descendingly
			public int compare(Integer a, Integer b) {
				ArrayList<Integer> l1 = base.get(a);
				ArrayList<Integer> l2 = base.get(b);
				if (l1.get(l1.size()-1) >= l2.get(l2.size()-1)) {
		            return -1;
		        } else {
		            return 1;
		        } // 
		    }
		}

}
