#
#
#
#
#include <iostream>
#include <fstream>
#include <sstream>
#include <list>
#include <string>
#include <vector>
#include <typeinfo> 
#include "TLorentzVector.h"


class ThreeVector {
  public:
    ThreeVector()
      :x(0.0), y(0.0), z(0.0)
    {}

    ThreeVector(double ax, double ay, double az)
      :x(ax), y(ay), z(az)
    {}

    inline double getX() const { return x; }
    inline double getY() const { return y; }
    inline double getZ() const { return z; }

    inline double perp() const { return std::sqrt(x*x + y*y); }
    inline double perp2() const { return x*x + y*y; }
    /**
     * Get the length of the vector.
     */
    inline double mag() const { return std::sqrt(x*x + y*y + z*z); }

    /**
     * Get the square of the length.
     */
    inline double mag2() const { return (x*x + y*y + z*z); }

      private:
        double x, y, z; //> Vector components
    }; 
 
 const double effectiveNucleonMass = 938.2796;
const  double theRealProtonMass = 938.27203;
 const double theRealNeutronMass = 939.56536;
 const double theRealChargedPiMass = 139.57018;
 const double theRealPiZeroMass = 134.9766;

 const double pi = 3.14159265358979323846264338328;
 const double tenPi = 10.0 * pi;
 

const int mediumNucleiTableSize = 30;
const int maxClusterMass = 12;
const int maxClusterCharge = 8;

const int clusterTableZSize = maxClusterCharge+1;
const int clusterTableASize = maxClusterMass+1;

const double mediumDiffuseness[mediumNucleiTableSize] =
{0.0,0.0,0.0,0.0,0.0,1.78,1.77,1.77,1.77,1.71,
  1.69,1.69,1.635,1.730,1.81,1.833,1.798,
  1.841,0.567,0.571, 0.560,0.549,0.550,0.551,
  0.580,0.575,0.569,0.537,0.0,0.0};
  const double mediumRadius[mediumNucleiTableSize] =
  {0.0,0.0,0.0,0.0,0.0,0.334,0.327,0.479,0.631,0.838,
    0.811,1.07,1.403,1.335,1.25,1.544,1.498,1.513,
    2.58,2.77, 2.775,2.78,2.88,2.98,3.22,3.03,2.84,
    3.14,0.0,0.0};

    const double positionRMS[clusterTableZSize][clusterTableASize] = {
  /*     A=   0     1     2     3     4     5     6     7     8     9    10    11    12 */
  /* Z=0 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0},
  /* Z=1 */ {-1.0, -1.0, 2.10, 1.80, 1.70, 1.83, 2.60, 2.50, -1.0, -1.0, -1.0, -1.0, -1.0},
  /* Z=2 */ {-1.0, -1.0, -1.0, 1.80, 1.68, 1.70, 2.60, 2.50, 2.50, 2.50, 2.50, -1.0, -1.0},
  /* Z=3 */ {-1.0, -1.0, -1.0, -1.0, 1.70, 1.83, 2.56, 2.40, 2.50, 2.50, 2.50, 2.50, 2.50},
  /* Z=4 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.60, 2.50, 2.50, 2.51, 2.50, 2.50, 2.50},
  /* Z=5 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.50, 2.50, 2.50, 2.50, 2.45, 2.40, 2.50},
  /* Z=6 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.50, 2.50, 2.50, 2.50, 2.47},
  /* Z=7 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.50, 2.50, 2.50},
  /* Z=8 */ {-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.50}
    };
   
  // INCL++ geometric Cross sections

      double getRealMass( int A,  int Z) ;
      double getRealMass( std::string t) ;
      double getRadiusParameter(std::string t, const int A, const int Z);
      double getNuclearRadius(std::string t, const int A, const int Z) ;
      double getMaximumNuclearRadius(std::string t, const int A, const int Z);
      int getIsospin(std::string t) ;
      double getSurfaceDiffuseness(std::string t, const int A, const int Z) ;
      double interactionDistancePiN(std::string t, TLorentzVector pp);
      double interactionDistanceNN(std::string t, TLorentzVector pp);
      double MaxinteractionDistanceNN(std::string t, TLorentzVector pp, int At,int Zt);
      //double total(double p1, double p2, double e1, double e2, std::string tp1, std::string tp2) ;
      double total(TLorentzVector pp1, TLorentzVector pt1, std::string tp1, std::string tp2);
      //double piNTot(double p1, double p2, double e1, double e2,std::string tp1, std::string tp2);
      double piNTot(TLorentzVector pp1, TLorentzVector pt1, std::string tp1, std::string tp2);
      //double NNTot(double p1,double p2, double e1, double e2, std::string tp1, std::string tp2);
      double NNTot(TLorentzVector pp1, TLorentzVector pt1, std::string tp1, std::string tp2);
      double momentumInLab(const double s, const double m1, const double m2) ;
      double NNTotFixed(const double s, const int i);
      double spnPiPlusPHE(const double x);
      double spnPiMinusPHE(const double x);
      std::string ParticleSpecies(std::string part);
      //double totalEnergyInCM(double p1, double p2, double e1, double e2);
      //double squareTotalEnergyInCM(double p1, double p2, double e1, double e2);
      double totalEnergyInCM(TLorentzVector pp1, TLorentzVector pt1);
      double squareTotalEnergyInCM(TLorentzVector pp1, TLorentzVector pt1);
      //double minimumDistance(const std::string p, const double kineticEnergy, const int A, const int Z) ;
      //double initUniverseRadius(const int A, const int Z, double kineticEnergy, std::string t);
      
      double minimumDistance(const std::string p, TLorentzVector pp, const int A, const int Z) ;
      double initUniverseRadius(const int A, const int Z, TLorentzVector pp, std::string t);


      //double maxImpactParameter(std::string p, const double kinE, const int A, const int Z);
        double maxImpactParameter(std::string p, TLorentzVector pp, const int A, const int Z);
   
      double maxImpactParameter(std::string p, TLorentzVector pp,const int A, const int Z) {
      
      const double theMinimumDistance = minimumDistance(p, pp, A,Z);
      //double rMax = initUniverseRadius(A,Z,pp,p);

      double rMax = MaxinteractionDistanceNN(p,pp,A,Z);
      //if(p.theType == Composite)
        //rMax +=  2.*ParticleTable::getLargestNuclearRadius(p.theA, p.theZ);
      double theMaxImpactParameterSquared = rMax*(rMax-theMinimumDistance);
      if(theMaxImpactParameterSquared<=0.)
        return 0.;
      const double theMaxImpactParameter = std::sqrt(theMaxImpactParameterSquared);
      
       return theMaxImpactParameter;
    }

    double getRealMass( int A,  int Z) {
      assert(A>=0);
      // For nuclei with Z<0 or Z>A, assume that the exotic charge state is due to pions
      if(Z<0)
        return A*theRealNeutronMass - Z*getRealMass("PiMinus");
      else if(Z>A)
        return A*theRealProtonMass + (A-Z)*getRealMass("PiPlus");
      else if(Z==0)
        return A*getRealMass("Neutron");
      else if(A==Z)
        return A*getRealMass("Proton");
         else if(A>1)
        return Z*(theRealProtonMass - 6.83) + (A-Z)*( theRealNeutronMass- 6.83) ;// 6.83 is the separation energy
      else
        return 0.;
    }
    double getRealMass( std::string t)   {
      if(t=="Proton") return theRealProtonMass;
      else if (t=="Neutron")return theRealNeutronMass;
      else if (t=="PiPlus"||t=="PiMinus") return theRealChargedPiMass;
      else if (t=="PiZero")return theRealPiZeroMass;
      else return 0;
    }
    
    double minimumDistance(const std::string p, TLorentzVector pp, const int A, const int Z) {
      const double particleMass = getRealMass(p);
      const double nucleusMass = getRealMass(A,Z);
      const double reducedMass = (particleMass*nucleusMass)/(particleMass+nucleusMass);
      const double kineticEnergyInCM = ((pp.E()-pp.M()) * reducedMass )/ particleMass;
      const double theMinimumDistance = 1.439964 * 1 * Z * particleMass / (kineticEnergyInCM * reducedMass); // For now we will only use proton as projectile Z =1 change it latter
        return theMinimumDistance;
      }

      double getRadiusParameter(std::string t, const int A, const int Z) {
        double neutronSkin(0.0);
        assert(A>0);
        if(A >= 28) {
        // phenomenological radius fit
          double r0 = (2.745e-4 * A + 1.063) * std::pow(A, 1.0/3.0);
          if(t=="Neutron")
            r0 += neutronSkin;
          return r0;
        } else if(A < 6 && A >= 2) {
          if(Z<clusterTableZSize && Z>=0) {
            const double thisRMS = positionRMS[Z][A];
            if(thisRMS>0.0)
              return thisRMS;
            else {
              return positionRMS[6][12];
            }
          } else {
            return positionRMS[6][12];
          }
        } else if(A < 28 && A >= 6) {
          return mediumRadius[A-1];
        //      return 1.581*mediumDiffuseness[A-1]*(2.+5.*mediumRadius[A-1])/(2.+3.*mediumRadius[A-1]);
        } 
      }

      double getNuclearRadius(std::string t, const int A, const int Z) {
        assert(A>=0);
        if(A >= 19 || (A < 6 && A >= 2)) {
        // For large (Woods-Saxon or Modified Harmonic Oscillator) or small
        // (Gaussian) nuclei, the radius parameter is just the nuclear radius
          return getRadiusParameter(t,A,Z);
        } else if(A < clusterTableASize && Z>=0 && Z < clusterTableZSize && A >= 6) {
          const double thisRMS = positionRMS[Z][A];
          if(thisRMS>0.0)
            return thisRMS;
          else {
            return positionRMS[6][12];
          }
        } else if(A < 19) {
          const double theRadiusParameter = getRadiusParameter(t, A, Z);
          const double theDiffusenessParameter = getSurfaceDiffuseness(t, A, Z);
        // The formula yields the nuclear RMS radius based on the parameters of
        // the nuclear-density function
          return 1.225*theDiffusenessParameter*
          std::sqrt((2.+5.*theRadiusParameter)/(2.+3.*theRadiusParameter));
        } 
      }
      double getMaximumNuclearRadius(std::string t, const int A, const int Z) {
        const double XFOISA = 8.0;
        if(A >= 19) {
          return getNuclearRadius(t,A,Z) + XFOISA * getSurfaceDiffuseness(t,A,Z);
        } else if(A < 19 && A >= 6) {
          return 5.5 + 0.3 * (double(A) - 6.0)/12.0;
        } else if(A >= 2) {
          return getNuclearRadius(t, A, Z) + 4.5;
        } else {
          return 0.0;
        }
      }

      double getSurfaceDiffuseness(std::string t, const int A, const int Z) {
        double neutronHalo(0.0);
        if(A >= 28) {
          double a = 1.63e-4*A + 0.510;
          if(t=="Neutron") a += neutronHalo;
          return a;
        } else if(A < 28 && A >= 19) {
          return mediumDiffuseness[A-1];
        } else if(A < 19 && A >= 6) {
          return mediumDiffuseness[A-1];
        }
      }
    double interactionDistancePiN(std::string t, TLorentzVector pp) {
double p2 = std::pow(pp.Pz(),2);
double propz = pp.Pz();

double enepipm = theRealChargedPiMass + (pp.E()-pp.M());
double enepizero = theRealPiZeroMass + (pp.E()-pp.M());

double enepipm2 = enepipm*enepipm - theRealChargedPiMass*theRealChargedPiMass;
 double enepizero2 = enepizero*enepizero -theRealPiZeroMass*theRealPiZeroMass;

 double adjustEnergyfromMpipm = std::sqrt(enepipm/p2);
 double adjustEnergyfromMpiZero = std::sqrt(enepizero2/p2);

      TLorentzVector PiplusPr(0.,0.,propz,enepipm);

      TLorentzVector PiminusPr(0.0,0.,propz,enepipm);

      TLorentzVector PizeroPr(0.,0.,propz,enepizero);

      double protonTrE = theRealProtonMass;
      double neutronTrE = theRealNeutronMass;
      double protonTrPz = 0.0;
      double neutronTrPz =0.0;


      TLorentzVector protonTR(0.0,0.0,  protonTrPz,protonTrE);
      TLorentzVector neutronTR(0.0,0.0, neutronTrPz, neutronTrE);
      const double sigmapipp = total(PiplusPr, protonTR,"PiPlus","Proton");
      const double sigmapipn = total(PiplusPr, neutronTR,"PiPlus","Neutron");
      const double sigmapimp = total(PiminusPr, protonTR,"PiMinus","Proton");
      const double sigmapimn = total(PiminusPr, neutronTR,"PiMinus","Neutron");
      const double sigmapi0p = total(PizeroPr, protonTR,"PiZero","Proton");
      const double sigmapi0n = total(PizeroPr, neutronTR,"PiZero","Neutron");
      /* We compute the interaction distance from the largest of the pi-N cross
       * sections. Note that this is different from INCL4.6, which just takes the
       * average of the six, and will in general lead to a different geometrical
       * cross section.
       */
      const double largestSigma = std::max(sigmapipp, std::max(sigmapipn, std::max(sigmapi0p, std::max(sigmapi0n, std::max(sigmapimp,sigmapimn)))));
      const double interactionDistance = std::sqrt(largestSigma/(10.0 * pi));

      return interactionDistance;
    }

      double MaxinteractionDistanceNN(std::string t, TLorentzVector pp, int At, int Zt){
        int A,Z;
        if (t=="Proton"){
          A=1;
          Z=1;
        }else if(t=="Neutron"){
          A=1;
          Z=0;
        }
       //const double r0 = std::max(getMaximumNuclearRadius("Proton", At, Zt), // Max interaction distance taloha
         //                          getMaximumNuclearRadius("Neutron", At, Zt));
       const double r0 = std::min(getMaximumNuclearRadius("Proton", At, Zt), // Max interaction distance taloha
                                   getMaximumNuclearRadius("Neutron", At, Zt));
       
        double theNNDistance(0.);
       if(ParticleSpecies(t)=="Nucleons")  theNNDistance = interactionDistanceNN(t, pp);
       else if (ParticleSpecies(t)=="Pions") theNNDistance = interactionDistancePiN(t,pp);
        
        double maxInteractionDistance = r0 + theNNDistance;
        
        return maxInteractionDistance ;
      } 
      double interactionDistanceNN(std::string t, TLorentzVector pp) {
        int A,Z;
        double propz = pp.Pz();

        const double p2 = std::pow(pp.Pz(),2);
        if (t=="Proton"){
          A=1;
          Z=1;
        }else if(t=="Neutron"){
          A=1;
          Z=0;
        }
        assert((A==1&&Z==1)|| (A==1&&Z==0));
        assert(A>0);
 
 const double kineticEnergyPerNucleon = (pp.E()-pp.M())/ A;
 double Eproj = theRealProtonMass + kineticEnergyPerNucleon;
 const double ene2 = Eproj*Eproj- theRealProtonMass*theRealProtonMass;
 const double adjustMomentumFromEnergy = std::sqrt(ene2/p2);

 
// neutron 
 double EprojNeutr = theRealNeutronMass + kineticEnergyPerNucleon;
 const double eneneutron2 = EprojNeutr*EprojNeutr -theRealNeutronMass*theRealNeutronMass;
 const double adjustMomentumFromEnergyNeutron = std::sqrt(eneneutron2/p2);
        //double protonPrP = std::sqrt(protonPrE*protonPrE- theRealProtonMass*theRealProtonMass );
        

        TLorentzVector protonPr(0.0,0.0,propz*adjustMomentumFromEnergy,Eproj);
        double neutronPrE = theRealNeutronMass + kineticEnergyPerNucleon;
        double neutronPrPz = std::sqrt(neutronPrE*neutronPrE - theRealNeutronMass*theRealNeutronMass);
        //TLorentzVector neutronPr(0.0,0.0,neutronPrPz,neutronPrE);

        TLorentzVector neutronPr(0.0,0.0,neutronPrPz*adjustMomentumFromEnergyNeutron,neutronPrE);
        double protonTrE = theRealProtonMass;
        double neutronTrE = theRealNeutronMass;
        double protonTrPz = 0.0;
        double neutronTrPz =0.0;

        TLorentzVector protonTR(0.0,0.0,  protonTrPz,protonTrE);
        TLorentzVector neutronTR(0.0,0.0, neutronTrPz, neutronTrE);

        const double sigmapp = total(protonPr,protonTR,"Proton","Proton");
        const double sigmapn = total(protonPr,neutronTR,"Proton","Neutron");
        const double sigmann = total(neutronPr,neutronTR,"Neutron","Neutron");

        const double largestSigma = std::max(sigmapp, std::max(sigmapn, sigmann));
        const double interactionDistance = std::sqrt(largestSigma/(10*3.14));

        return interactionDistance;
      }

      double total(TLorentzVector pp1,TLorentzVector pt1, std::string tp1, std::string tp2) {
        double inelastic;
        if((ParticleSpecies(tp1)=="Nucleons"&&ParticleSpecies(tp2)=="Nucleons")||
          (ParticleSpecies(tp1)=="Nucleons"&&ParticleSpecies(tp2)=="Nucleons"))return NNTot(pp1,pt1,tp1,tp2);
       //else if((p1->isNucleon() && p2->isDelta()) ||
          //      (p1->isDelta() && p2->isNucleon())) {
        //inelastic = NDeltaToNN(p1, p2);} 
      else if((ParticleSpecies(tp1)=="Nucleons"&&ParticleSpecies(tp2)=="Pions")||
        (ParticleSpecies(tp1)=="Pions"&&ParticleSpecies(tp2)=="Nucleons")) return piNTot(pp1,pt1,tp1,tp2);
      
       //else  inelastic = 0.;
      //return inelastic + elastic(p1, p2);
            }

    std::string ParticleSpecies(std::string part){
      if(part=="Neutron"|| part=="Proton") return "Nucleons";
      else if(part=="PiPlus"||part=="PiMinus"||part=="PiZero") return "Pions";
    }


    double piNTot(TLorentzVector pp1,TLorentzVector pp2,std::string tp1, std::string tp2) {
      double x = totalEnergyInCM(pp1,pp2);

      int ipit3 = 0;
      int ind2t3 = 0;

      if(tp1=="PiZero"||tp1=="PiMinus"||tp1=="PiPlus") {
        ipit3 = getIsospin(tp1);
        ind2t3 = getIsospin(tp2);
      } else if(tp2=="PiZero"||tp2=="PiMinus"||tp2=="PiPlus") {
        ipit3 = getIsospin(tp2);
        ind2t3 = getIsospin(tp1);
      }

      double spnResult=0.0;

      // HE pi+ p and pi- n
      if((ind2t3 == 1 && ipit3 == 2) || (ind2t3 == -1 && ipit3 == -2))
        spnResult=spnPiPlusPHE(x);
      else if((ind2t3 == 1 && ipit3 == -2) || (ind2t3 == -1 && ipit3 == 2))
        spnResult=spnPiMinusPHE(x);
        else if(ipit3 == 0) spnResult = (spnPiPlusPHE(x) + spnPiMinusPHE(x))/2.0; // (spnpipphe(x)+spnpimphe(x))/2.0
        else {
          std::cout<<"Unknown configuration! "  << '\n';
        }

        return spnResult;
      }


      double NNTot(TLorentzVector pp1, TLorentzVector pt1, std::string tp1, std::string tp2) {

        int i = getIsospin(tp1)+ getIsospin(tp2);

       // if((tp1=="Neutron" ||tp1=="Proton" )&& (tp2=="Proton"||tp2=="Neutron") {  // NN
          const double s = squareTotalEnergyInCM(pp1, pt1);
          return NNTotFixed(s, i);
          
        //}
        /*
        else if (part1->isDelta() && part2->isDelta()) {  // Delta-Delta
            return elastic(part1, part2);
        }
        else {  // Nucleon-Delta
            return NDeltaToNN(part1, part2) + elastic(part1, part2);
        }*/
      
}
        double momentumInLab(const double s, const double m1, const double m2) {
          const double m1sq = m1*m1;
          const double m2sq = m2*m2;
          double plab2 = (s*s-2*s*(m1sq+m2sq)+(m1sq-m2sq)*(m1sq-m2sq))/(4*m2sq);
          if(plab2 < 0.0) {
            plab2 = 0.0;
          }
          return std::sqrt(plab2);
        }

        double NNTotFixed(const double s, const int i) {

      /* From NNTot, with isospin fixed and for NN only.
      */

          double plab = 0.001*momentumInLab(s,effectiveNucleonMass,effectiveNucleonMass);

      if (i == 0) {  // pn
        if (plab < 0.446) {
          double alp=std::log(plab);
          return 6.3555*std::exp(-3.2481*alp-0.377*std::pow(alp, 2));
        }
        else if (plab < 1.0) {
          return 33.+196.*std::sqrt(std::pow(std::fabs(plab-0.95),5));
        }
        else if (plab < 1.924) {
          return 24.2+8.9*plab;
        }
        else {
          double alp=std::log(plab);
          return 48.9-33.7*std::pow(plab, -3.08)+0.619*std::pow(alp, 2)-5.12*alp;
        }
      }
      else {  // pp and nn
        if (plab < 0.440) {
          return 34.*std::pow(plab/0.4, (-2.104));
        }
        else if (plab < 0.8734) {
          return 23.5+1000.*std::pow(plab-0.7, 4);
        }
        else if (plab < 1.5) {
          return 23.5+24.6/(1.+std::exp(-10.*(plab-1.2)));
        }
        else if (plab < 3.0044) {
          return 41.+60.*(plab-0.9)*std::exp(-1.2*plab);
        }
        else {
          double alp=std::log(plab);
          return 45.6+219.*std::pow(plab, -4.23)+0.41*std::pow(alp, 2)-3.41*alp;
        }
      }
    }


    double spnPiPlusPHE(const double x) {
        // HE and LE pi- p and pi+ n
      double ramass = 0.0;

      if(x <= 1306.0) {
       double y = x*x;
       double q2;
       q2=(y-std::pow(1076.0, 2))*(y-std::pow(800.0, 2))/(4.0*y);
       if (q2 > 0.) {
        double q3=std::pow(q2, 3./2.);
        double f3=q3/(q3+std::pow(180.0, 3));
        double sdel;
        sdel=326.5/(std::pow((x-1215.0-ramass)*2.0/110.0,2)+1.0);
        return sdel*f3*(1.0-5.0*ramass/1215.0);
      }
      else {
        return 0;
      }
    }
    if(x <= 1754.0) {
      return -2.33730e-06*std::pow(x, 3)+1.13819e-02*std::pow(x,2)
      -1.83993e+01*x+9893.4;
    } else if (x <= 2150.0) {
      return 1.13531e-06*std::pow(x, 3)-6.91694e-03*std::pow(x, 2)
      +1.39907e+01*x-9360.76;
    } else {
      return -3.18087*std::log(x)+52.9784;
    }
  }

  double spnPiMinusPHE(const double x) {
        // HE pi- p and pi+ n
    double ramass = 0.0;

    if(x <= 1275.8) {
     double y = x*x;
     double q2;
     q2=(y-std::pow(1076.0, 2))*(y-std::pow(800.0, 2))/(4.0*y);
     if (q2 > 0.) {
      double q3=std::pow(q2, 3./2.);
      double f3=q3/(q3+std::pow(180.0, 3));
      double sdel;
      sdel=326.5/(std::pow((x-1215.0-ramass)*2.0/110.0,2)+1.0);
      return sdel*f3*(1.0-5.0*ramass/1215.0)/3.;
    }
    else {
      return 0;
    }
  }
  if(x <= 1495.0) {
    return 0.00120683*(x-1372.52)*(x-1372.52)+26.2058;
  } else if(x <= 1578.0) {
    return 1.15873e-05*x*x+49965.6/((x-1519.59)*(x-1519.59)+2372.55);
  } else if(x <= 2028.4) {
    return 34.0248+43262.2/((x-1681.65)*(x-1681.65)+1689.35);
  } else if(x <= 7500.0) {
    return 3.3e-7*(x-7500.0)*(x-7500.0)+24.5;
  } else {
    return 24.5;
  }
}
      /*ThreeVector makeBoostVector(double p1, double p2, double e1, double e2){
        const double totalEnergy = e1+e2;
        return (p1+p2/totalEnergy);
      }*/

double totalEnergyInCM(TLorentzVector pp1, TLorentzVector pt1){
  return std::sqrt(squareTotalEnergyInCM(pp1,pt1));
}

double squareTotalEnergyInCM(TLorentzVector pp1, TLorentzVector pt1) {
  //double makeBoost = (p1+p2)/(e1+e2);
  double totalenergy= pp1.E() + pt1.E();
  ThreeVector makeBoost((pp1.Px()+pt1.Px())/totalenergy, (pp1.Py()+pt1.Py())/totalenergy, (pp1.Pz()+pt1.Pz())/totalenergy);

        double beta2 = makeBoost.mag2(); //
        if(beta2 > 1.0) {
          beta2 = 0.0;
        }
        return (1.0 - beta2)*std::pow(pp1.E()+pt1.E(), 2);
      }


      double initUniverseRadius(const int A, const int Z, TLorentzVector pp, std::string t) {
        double rMax(0.0), maxUniverseRadius(0.0);
        //rMax = std::max(maximumRadius, rMax);
        const double pMaximumRadius = getMaximumNuclearRadius("Proton", A, Z);
        const double nMaximumRadius = getMaximumNuclearRadius("Neutron", A, Z);
        rMax = std::min(pMaximumRadius, nMaximumRadius);

        if( t=="Proton" || t=="Neutron") {
         const double interactionDistanceNNtp =interactionDistanceNN(t, pp);// MaxinteractionDistanceNN(t,pp); //      
            maxUniverseRadius = rMax + interactionDistanceNNtp;
      } 
      else if(t=="PiPlus"
          || t=="PiZero"
          || t=="PiMinus") {
        const double interactionDistancePiNtp = interactionDistancePiN(t,pp);
        maxUniverseRadius = rMax+ interactionDistancePiNtp;
      }
          return maxUniverseRadius;
        }
/*std::string getNameprojectile(std::string t)   {
        if(t == "Proton") {
        return Proton;
      } else if(t == "Neutron") {
        return Neutron;
      } else if(t == "PiPlus") {
        return PiPlus;
      } else if(t == "PiMinus") {
        return PiMinus;
      } else if(t == "PiZero") {
        return PiZero;
      } else if(t == "DeltaPlusPlus") {
        return DeltaPlus;
      } else if(t == "DeltaPlus") {
        return DeltaPlus;
      } else if(t == "DeltaZero") {
        return DeltaZero;
      } else if(t == "DeltaMinus") {
        return DeltaMinus;
      }
} 
*/
        int getIsospin(std::string t) {
      // Actually this is the 3rd component of isospin (I_z) multiplied by 2!
          if(t == "Proton") {
            return 1;
          } else if(t == "Neutron") {
            return -1;
          } else if(t == "PiPlus") {
            return 2;
          } else if(t == "PiMinus") {
            return -2;
          } else if(t == "PiZero") {
            return 0;
          } else if(t == "DeltaPlusPlus") {
            return 3;
          } else if(t == "DeltaPlus") {
            return 1;
          } else if(t == "DeltaZero") {
            return -1;
          } else if(t == "DeltaMinus") {
            return -3;
          }
      return -10; // Unknown
    }
