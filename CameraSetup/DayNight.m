function DayNight(obj,event,a,pin,ON)

event_time = datestr(event.Data.time);

        writeDigitalPin(a,pin,ON); % turn light ON/OFF
        T = ['Night','Day'];
        O = ['OFF','ON'];
        disp([event_time,' ',T(ON+1),' time: light is ',O(ON+1)])
end
