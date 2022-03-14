function [Lat Lon] = Grid2LatLon(X,Y,Type)

%Grid2LatLon:
%1.01 - ICS is used directly, instead of a pre-stage of a linear transformation between ITM and ICS.
%X is the X (LAT) value in the Israeli Grid.
%Y is the Y (LON) value in the Israeli Grid.
%Use Type = 0 for ICS (The Old Israeli Grid) or Type = 1 for ITM (The New Israeli Grid).


    %Resetting:
    Lon = 0;
    Lan = 0;
    
    %WGRS84 Constants:
    a = 6378137.0; %Earth's Equatorial Radius
    b = 6356752.3142; %Earth's Plar Radius
    f = 0.00335281066474748; %(a-b)/a; %Surface
    esq = 0.006694380004260807; %abs(1-(a*a)/(b*b));
    e = sqrt(esq); %Eccentricity

    %GRS80 Constants:
    a80 = 6378137.0; %Earth's Equatorial Radius
    b80= 6356752.3141; %Earth's Plar Radius
    f80 = 0.0033528106811823; %(a-b)/a; %Surface
    esq80 = 0.00669438002290272; %abs(1-(a*a)/(b*b));
    e80 = sqrt(esq); %Eccentricity
    dx80 = -48;
    dy80 = 55;
    dz80 = 52;

    %ICS (Old Grid) Constants:
    ICS(1) = 0.6145667421719; %lon0, which is 35.12'43.490"
    ICS(2) = 0.55386447682762762; %lat0, which is 31.44'02.749"
    ICS(3) = 1.0000; %Scale Vector
    ICS(4) = 170251.555; %False East
    ICS(5) = 2385259.0; %False North

    %ITM (New Grid) Constants:
    ITM(1) = 0.61443473225468920; %lon0, which is 35.12'16.261"
    ITM(2) = 0.5538696543774187; %lat0, which is 31.44'03.817"
    ITM(3) = 1.0000067; %Scale Vector
    ITM(4) = 219529.584; %False East
    ITM(5) = 2885516.9488; %False North
    % ICS -> ITM:
    if (Type == 0)
        %X = X + 50000
        %Y = Y - 500000
        ITM=ICS;
    
    end
    %ITM -> GRS80
    
    
        H = Y + ITM(5);
        W = X - ITM(4);
        M = H/ITM(3);
        
        mu = M/(a80*(1 - e80*e80/4 - (3*e80^4)/64 - (5*e80^6)/256));
        ee = sqrt(1-esq);
        e1 = (1-ee)/(1+ee);
        j1 = 3*e1/2 - (27*e1^3)/32;
        j2 = (21*e1^2)/16 - (55*e1^4)/32;
        j3 = (151*e1^3)/96;
        j4 = (1097*e1^4)/512;
        
        fp = mu + j1*sin(2*mu) + j2*sin(4*mu) + j3*sin(6*mu) + j4*sin(8*mu);
        
        sinfp = sin(fp);
        cosfp = cos(fp);
        tanfp = sinfp/cosfp;
        eg = (e80*a80/b80);
        eg2 = eg^2;
        C1 = eg2*cosfp^2;
        T1 = tanfp^2;
        R1 = a80*(1-e80^2)/((1-e80^2*sinfp^2)^1.5);
        N1 = a80/sqrt(1-e80^2*sinfp^2);
        D = W/(N1*ITM(3));
        
        Q1 = N1*tanfp/R1;
        Q2 = D^2/2;
        Q3 = (5+3*T1 + 10*C1 - 4*C1^2 - 9*eg^2)*D^4/24;
        Q4 = (61+90*T1 + 298*C1 + 45*T1^2 - 3*C1^2 - 252*eg2^2)*D^5/120;
        
        %lat80:
        lat80 = fp-Q1*(Q2-Q3+Q4);
        
        Q5 = D;
        Q6 = (1+2*T1+C1)*D^3/6;
        Q7 = (5-2*C1 + 28*T1 - 3*C1 + 8*eg2^2+24*T1^2)*D^5/120;
        
        %lon80:
        lon80 = ITM(1) + (Q5-Q6+Q7)/cosfp;
        
        
        dX=dx80-0;
        dY=dy80-0;
        dZ=dz80-0;
        slat = sin(lat80);
        clat = cos(lat80);
        slon = sin(lon80);
        clon = cos(lon80);
        ssqlat = slat^2;
        
        df = f-f80;
        da = a-a80;
        adb = 1/(1-f80);
        rn = a80/sqrt(1-esq80*ssqlat);
        rm = a80*(1-esq80)/((1-esq80*ssqlat).^1.5);
        from_h = 0.0;
        
        dlat = (-dX*slat*clon-dY*slat*slon+dZ*clat+da*rn*esq80*slat*clat/a80+df*(rm*adb+rn/adb)*slat*clat)/(rm+from_h);
        
        %Lat
        Lat=(lat80+dlat)*180/pi;
        
        dlon = (-dX*slon+dY*clon)/((rn+from_h)*clat);
        
        %Lon
        Lon=(lon80+dlon)*180/pi;
   


end