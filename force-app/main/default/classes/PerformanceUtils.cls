public class PerformanceUtils {

    public static Integer limitCPUTime{
        get{
            if(limitCPUTime == null){
                limitCPUTime = Limits.getLimitCpuTime();
            }
            return limitCPUTime;
        }set;
    }

    public static Integer limitSOQL{
        get{
            if(limitSOQL == null){
                limitSOQL = Limits.getLimitQueries();
            }
            return limitSOQL;
        }set;
    }

    public static Integer limitHeapSize{
        get{
            if(limitHeapSize == null){
                limitHeapSize = Limits.getLimitHeapSize();
            }
            return limitHeapSize;
        }set;
    }

    public static void checkMyPerformance(){
        System.debug('SOQL max : ' + limitSOQL + ' use : ' + Limits.getQueries());
        System.debug('CPU Time max : ' + limitCPUTime + ' use : ' + Limits.getCpuTime());
        System.debug('Heap max : ' + limitHeapSize + ' use : ' + Limits.getHeapSize());
    }
}