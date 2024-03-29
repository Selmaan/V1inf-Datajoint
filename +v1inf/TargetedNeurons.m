%{
# Nearest Cell for all control & unmatched stim targets
-> v1inf.Target
-----
neur_id: smallint unsigned         # Neuron ID sampled for this target
targ_type: enum('Matched','Unmatched','Control')    # type of photostim target
%}

classdef TargetedNeurons < dj.Computed
        
    methods(Access=protected)

        function makeTuples(self, key)
           thisTarg = fetch(v1inf.Target & key, 'targ_xc','targ_yc','targ_label','neur_id');
           [neurX,neurY,neurID] = fetchn(v1inf.Neuron & key,'neur_xc','neur_yc','neur_id');
           targDist = sqrt((neurX-thisTarg.targ_xc).^2 + (neurY-thisTarg.targ_yc).^2);
           
           nearbyNeur = find(targDist<=prctile(targDist,2));
           thisNeur = nearbyNeur(randi(length(nearbyNeur),1));
           key.neur_id = neurID(thisNeur);
           if thisTarg.targ_label > 0.99
               key.targ_type = 'Matched';
           elseif thisTarg.targ_label < 0.01
               key.targ_type = 'Control';
           else
               key.targ_type = 'Unmatched';
           end
           
           self.insert(key),
            
        end
	end
end