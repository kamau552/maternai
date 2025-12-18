# ============= NODE DEFINITIONS =============
node User {
    has username: str;
    has email: str;
    has password_hash: str;
    has user_type: str;
    has full_name: str;
    has created_at: str;
    has last_login: str;
    has profile_pic: str = "";
    has is_active: bool = True;
}

node Patient {
    has username: str;
    has email: str;
    has password_hash: str;
    has user_type: str;
    has full_name: str;
    has created_at: str;
    has last_login: str;
    has profile_pic: str = "";
    has is_active: bool = True;
    
    has age: int;
    has pregnancy_week: int;
    has blood_type: str;
    has phone: str;
    has emergency_contact: str;
    has address: str;
    has last_checkup: str;
    has insurance_provider: str;
    has primary_doctor: str;
    
    has location_lat: float = -1.286389;
    has location_lng: float = 36.817223;
    has risk_level: str = "Low";
}

node HealthMetric {
    has metric_type: str;
    has value: float;
    has unit: str;
    has timestamp: str;
    has is_abnormal: bool;
    has notes: str = "";
}

node RiskReport {
    has summary: str;
    has severity: str;
    has recommendation: str;
    has detected_at: str;
    has confidence: float;
    has reviewed_by: str = "";
}

node Symptom {
    has symptom_name: str;
    has severity: str;
    has description: str;
    has reported_at: str;
    has action_required: str;
    has follow_up_date: str = "";
}

node Appointment {
    has doctor_name: str;
    has appointment_date: str;
    has purpose: str;
    has status: str;
    has location: str;
    has duration_minutes: int = 30;
    has notes: str = "";
}

node CareTip {
    has title: str;
    has content: str;
    has trimester: int;
    has category: str;
    has created_at: str;
    has icon: str = "fas fa-heart";
    has image_url: str = "";
}

node HealthFacility {
    has name: str;
    has facility_type: str;
    has location_lat: float;
    has location_lng: float;
    has address: str;
    has phone: str;
    has services: list;
    has distance_km: float = 0.0;
    has rating: float = 4.5;
    has image_url: str = "";
}

node EmergencyAlert {
    has patient_name: str;
    has alert_type: str;
    has message: str;
    has timestamp: str;
    has status: str = "Active";
    has priority: str = "High";
    has assigned_to: str = "";
}

node ChatMessage {
    has sender: str;
    has message: str;
    has timestamp: str;
    has message_type: str;
    has is_read: bool = False;
}

# ==================== FIXED WALKERS ====================

walker seed_initial_data {
    can seed with root entry {
        # Check if already seeded
        check = [-->](`?User);
        if len(check) > 0 {
            report {"status": "Already seeded"};
            disengage;
        }

        # Create Patient node
        patient_node = Patient(
            username="sarah",
            email="sarah@example.com",
            password_hash="hashed_pass123",
            full_name="Sarah Johnson",
            user_type="patient",
            age=28,
            pregnancy_week=24,
            blood_type="A+",
            phone="+254712345678",
            emergency_contact="+254712345679",
            address="Nairobi, Kenya",
            last_checkup="2024-01-01",
            insurance_provider="NHIF",
            primary_doctor="Dr. Williams",
            created_at="2024-01-01T00:00:00",
            last_login="2024-01-01T00:00:00",
            risk_level="Low"
        );
        
        # Connect to root
        here ++> patient_node;

        # Create Health Metrics
        metric1 = HealthMetric(
            metric_type="BP Systolic", 
            value=120.0, 
            unit="mmHg", 
            timestamp="2024-01-01", 
            is_abnormal=False
        );
        patient_node ++> metric1;
        
        metric2 = HealthMetric(
            metric_type="Glucose", 
            value=150.0, 
            unit="mg/dL", 
            timestamp="2024-01-02", 
            is_abnormal=True
        );
        patient_node ++> metric2;
        
        # Create Appointment
        appt = Appointment(
            doctor_name="Dr. Williams", 
            appointment_date="2025-01-20", 
            purpose="Checkup", 
            status="Scheduled",
            location="City Hospital"
        );
        patient_node ++> appt;

        # Create Risk Report
        risk = RiskReport(
            summary="High Glucose Detected", 
            severity="Medium", 
            recommendation="Monitor sugar intake", 
            detected_at="2024-01-02",
            confidence=0.8
        );
        patient_node ++> risk;

        # Create Facilities
        facility1 = HealthFacility(
            name="City Hospital", 
            facility_type="General", 
            location_lat=-1.29, 
            location_lng=36.82, 
            address="City Center", 
            phone="12345",
            services=["Emergency", "Maternity"],
            rating=4.5
        );
        here ++> facility1;
        
        facility2 = HealthFacility(
            name="Maternity Clinic", 
            facility_type="Clinic", 
            location_lat=-1.28, 
            location_lng=36.81, 
            address="Westlands", 
            phone="67890",
            services=["Maternity", "Checkup"],
            rating=4.8
        );
        here ++> facility2;

        report {"status": "Seeded successfully"};
    }
}



walker init {
    can run with root entry {
        users = [-->](`?User);
        
        if len(users) == 0 {
            spawn here walker:seed_initial_data;
            report {"message": "Initial data seeded", "status": "success"};
        } else {
            report {"message": "Data already exists", "status": "skipped"};
        }
    }
}