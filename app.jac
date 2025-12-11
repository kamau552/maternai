# ============= MATERNAI - COMPLETE INTEGRATED PLATFORM =============
# Professional Maternal Health Platform with Integrated Backend & Frontend
# All in one app.jac file

# ==================== 1. OSP GRAPH NODES (Backend) ====================

node User {
    has username: str;
    has email: str;
    has password_hash: str;
    has user_type: str;
    has full_name: str;
    has profile_pic: str = "";
    has created_at: str;
    has last_login: str;
    has is_active: bool = True;
}

node Patient(User) {
    has age: int;
    has pregnancy_week: int;
    has blood_type: str;
    has phone: str;
    has emergency_contact: str;
    has address: str;
    has location_lat: float = -1.286389;
    has location_lng: float = 36.817223;
    has risk_level: str = "Low";
    has last_checkup: str;
    has insurance_provider: str;
    has primary_doctor: str;
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
    has severity: str; # "Low", "Medium", "High", "Critical"
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
    has status: str; # "Scheduled", "Completed", "Cancelled", "Rescheduled"
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
    has message_type: str; # "text", "symptom", "emergency", "info"
    has is_read: bool = False;
}

# ==================== 2. BACKEND WALKERS ====================

# AUTHENTICATION
walker register_user {
    has username: str;
    has email: str;
    has password: str;
    has full_name: str;
    has user_type: str = "patient";
    has age: int = 0;
    has pregnancy_week: int = 0;

    can register with root entry {
        # Traverses all nodes descended from root to find existing Users (including Patients)
        existing_users = [root -->](`?User);

        for u in existing_users {
            if u.email == self.email or u.username == self.username {
                report {"success": false, "error": "User already exists"};
                disengage;
            }
        }

        # Simple password hash
        password_hash = "hashed_" + self.password;

        if self.user_type == "patient" {
            # Create a new Patient node attached to the root
            new_user = root ++> Patient(
                username=self.username,
                email=self.email,
                password_hash=password_hash,
                full_name=self.full_name,
                user_type=self.user_type,
                age=self.age,
                pregnancy_week=self.pregnancy_week,
                created_at="Now",
                last_login="Now"
            );
        } else {
            # Create a new generic User node attached to the root
            new_user = root ++> User(
                username=self.username,
                email=self.email,
                password_hash=password_hash,
                full_name=self.full_name,
                user_type=self.user_type,
                created_at="Now",
                last_login="Now"
            );
        }

        report {"success": true, "user_id": new_user.id, "message": "Registration successful"};
    }
}


walker login_user {
    has email: str;
    has password: str;

    can authenticate with root entry {
        # Get all User nodes connected from root
        users = [root -->](`?User);

        for user in users {
            if user.email == self.email {
                # Check password
                expected_hash = "hashed_" + self.password;
                if user.password_hash == expected_hash and user.is_active {
                    # Update last login timestamp
                    user.last_login = "Now";

                    # Prepare user data dictionary
                    user_data = {
                        "id": user.id,
                        "username": user.username,
                        "email": user.email,
                        "full_name": user.full_name,
                        "user_type": user.user_type,
                        "profile_pic": user.profile_pic
                    };

                    # If user is a patient, add patient-specific info using typed context block
                    with Patient as patient_node {
                        if user.id == patient_node.id {
                            user_data["age"] = patient_node.age;
                            user_data["pregnancy_week"] = patient_node.pregnancy_week;
                            user_data["blood_type"] = patient_node.blood_type;
                            user_data["risk_level"] = patient_node.risk_level;
                            user_data["phone"] = patient_node.phone;
                            user_data["location_lat"] = patient_node.location_lat;
                            user_data["location_lng"] = patient_node.location_lng;
                        }
                    }

                    report {"success": True, "user": user_data};
                    disengage;
                }
            }
        }

        report {"success": False, "error": "Invalid credentials"};
    }
}

# MULTI-AGENT SYSTEM
walker care_advisor {
    has patient_id: str;
    has trimester: int;
    has question: str = "";

    can provide_advice with root entry {
        # Simulate AI-generated advice
        base_tips = [];

        if self.question != "" {
            # Simulate AI response to specific question
            ai_response = "Based on your question about '" + self.question + "', I recommend: ";

            if "nutrition" in self.question.lower() {
                ai_response += "Focus on a balanced diet with plenty of leafy greens, lean proteins, and whole grains. Stay hydrated and consider prenatal vitamins.";
            } elif "exercise" in self.question.lower() {
                ai_response += "Moderate exercise like walking or prenatal yoga for 30 minutes daily is beneficial. Avoid high-impact activities and listen to your body.";
            } elif "symptoms" in self.question.lower() {
                ai_response += "Monitor symptoms closely. Common discomforts are normal, but contact your doctor for severe pain, bleeding, or reduced fetal movement.";
            } else {
                ai_response += "Maintain regular checkups, stay hydrated, and get adequate rest. Contact your healthcare provider for any concerns.";
            }

            base_tips.append({
                "title": "AI Response",
                "content": ai_response,
                "icon": "fas fa-robot",
                "category": "AI Advice",
                "is_ai": True
            });
        }

        # Trimester-specific tips
        if self.trimester == 1 {
            base_tips.append({
                "title": "First Trimester Essentials",
                "content": "Focus on folate intake, manage morning sickness with small frequent meals, and schedule your first prenatal appointment.",
                "icon": "fas fa-baby",
                "category": "Nutrition",
                "is_ai": False
            });
        } elif self.trimester == 2 {
            base_tips.append({
                "title": "Second Trimester Wellness",
                "content": "This is often the most comfortable trimester. Consider prenatal yoga, plan your maternity leave, and monitor fetal movements.",
                "icon": "fas fa-heartbeat",
                "category": "Wellness",
                "is_ai": False
            });
        } else {
            base_tips.append({
                "title": "Third Trimester Preparation",
                "content": "Prepare your hospital bag, practice breathing techniques, monitor for signs of labor, and finalize birth plan.",
                "icon": "fas fa-hospital",
                "category": "Preparation",
                "is_ai": False
            });
        }

        report {"tips": base_tips, "ai_generated": len(base_tips) > 0};
    }
}

#AI chatbot
walker ai_chatbot {
    has user_id: str;
    has message: str;
    has message_type: str = "text";

    can respond with root entry {
        # Simulate AI response based on message content
        response = "";
        quick_replies = [];

        message_lower = self.message.lower();

        if any(word in message_lower for word in ["hello", "hi", "hey"]) {
            response = "Hello! I'm your MaternAI assistant. How can I help you today?";
            quick_replies = ["Check symptoms", "Find hospital", "Care tips", "Emergency help"];
        } elif any(word in message_lower for word in ["symptom", "pain", "hurt", "feel"]) {
            response = "I can help assess your symptoms. Please describe what you're feeling in detail, or use our symptom checker for immediate assessment.";
            quick_replies = ["Open symptom checker", "Emergency symptoms", "Schedule appointment"];
        } elif any(word in message_lower for word in ["hospital", "clinic", "doctor", "emergency"]) {
            response = "I can help you find nearby healthcare facilities. Would you like me to search for hospitals, clinics, or maternity centers?";
            quick_replies = ["Find hospitals", "Nearest clinic", "Emergency services"];
        } elif any(word in message_lower for word in ["tip", "advice", "care", "healthy"]) {
            response = "I can provide personalized care advice. Are you in your first, second, or third trimester?";
            quick_replies = ["First trimester", "Second trimester", "Third trimester"];
        } elif any(word in message_lower for word in ["appointment", "schedule", "visit"]) {
            response = "I can help you schedule appointments. Would you like to book a routine checkup, ultrasound, or specialist consultation?";
            quick_replies = ["Routine checkup", "Ultrasound", "Specialist"];
        } elif any(word in message_lower for word in ["emergency", "urgent", "help", "critical"]) {
            response = "⚠️ EMERGENCY ASSISTANCE: If you're experiencing severe symptoms, please call emergency services immediately at 112 or go to the nearest hospital.";
            quick_replies = ["Call emergency", "Find nearest hospital", "Critical symptoms"];
        } else {
            response = "I'm here to assist with your maternal health questions. You can ask me about symptoms, find healthcare facilities, get care tips, or schedule appointments.";
            quick_replies = ["Symptom help", "Find hospital", "Care advice", "Book appointment"];
        }

        # Store chat message node
        root ++> ChatMessage(
            sender="ai_chatbot",
            message=self.message,
            timestamp="Now",
            message_type=self.message_type,
            is_read=True
        );

        report {
            "response": response,
            "quick_replies": quick_replies,
            "timestamp": "Now"
        };
    }
}

walker emergency_coordinator {
    # Use ':' for types and '=' for default values
    has patient_id: str = "";
    has emergency_type: str = "";
    has location_lat: float = 0.0;
    has location_lng: float = 0.0;

    can coordinate_emergency with `root entry {
        # Find nearest facilities
        facilities = [];

        # Use backtick for type filter `?HealthFacility
        all_facilities = [-->](`?HealthFacility);

        for facility in all_facilities {
            # Calculate distance (simplified Euclidean)
            lat_diff = self.location_lat - facility.location_lat;
            lng_diff = self.location_lng - facility.location_lng;

            # Simple math logic
            dist_sq = (lat_diff * lat_diff) + (lng_diff * lng_diff);
            distance = (dist_sq ** 0.5) * 111.0;

            # Use braces {} for if statements
            if distance <= 20.0 {
                facilities.append({
                    "name": facility.name,
                    "distance": distance,
                    "phone": facility.phone,
                    "address": facility.address,
                    "services": facility.services
                });
            }
        }

        # Use Jac 'sorted' to sort the list based on 'distance'
        sorted_facilities = sorted(
            facilities,
            lambda x: float -> float { return x["distance"]; }
        );

        # Create emergency alert
        alert_message = "EMERGENCY: " + self.emergency_type + " reported by patient " + self.patient_id;

        root ++> EmergencyAlert(
            patient_name=self.patient_id,
            alert_type="Critical",
            message=alert_message,
            timestamp="Now",
            status="Active",
            priority="Highest"
        );

        # Generate emergency instructions
        instructions = [];

        if self.emergency_type == "Severe Bleeding" {
            instructions = [
                "1. Lie down and elevate legs",
                "2. Apply pressure to bleeding area if accessible",
                "3. Do NOT insert anything into vagina",
                "4. Keep warm with blanket",
                "5. Await ambulance - DO NOT drive yourself"
            ];
        } elif self.emergency_type == "Severe Pain" {
            instructions = [
                "1. Find comfortable position",
                "2. Practice deep breathing",
                "3. Time contractions if applicable",
                "4. Monitor for bleeding or fluid leakage",
                "5. Prepare for hospital transfer"
            ];
        } elif self.emergency_type == "Decreased Movement" {
            instructions = [
                "1. Drink cold water or juice",
                "2. Lie on left side",
                "3. Count fetal movements for 2 hours",
                "4. Note any movement patterns",
                "5. Proceed to hospital if less than 10 movements"
            ];
        } else {
            instructions = [
                "1. Stay calm and sit/lie down",
                "2. Call emergency services (112)",
                "3. Have someone stay with you",
                "4. Gather medical documents",
                "5. Await professional help"
            ];
        }

        # Report the top 3 nearest facilities
        report {
            "emergency_alerted": True,
            "nearest_facilities": sorted_facilities[:3],
            "emergency_instructions": instructions,
            "timestamp": "Now"
        };
    }
}

# APPOINTMENT SCHEDULING
walker appointment_scheduler {
    has patient_id: str;
    has doctor_name: str;
    has preferred_date: str;
    has purpose: str;
    
    can schedule_appointment with root entry {
        # Simulate appointment scheduling
        appointment_id = "APT" + str(now().timestamp()).replace(".", "")[-8:];
        
        # Create appointment node
        root ++> Appointment(
            doctor_name=self.doctor_name,
            appointment_date=self.preferred_date,
            purpose=self.purpose,
            status="Scheduled",
            location="Main Hospital - Room 205",
            duration_minutes=30,
            notes="Patient requested: " + self.purpose
        );
        
        # Generate confirmation
        confirmation = {
            "appointment_id": appointment_id,
            "doctor": self.doctor_name,
            "date": self.preferred_date,
            "time": "10:00 AM",
            "location": "Main Hospital - Room 205",
            "duration": "30 minutes",
            "preparation_notes": [
                "Arrive 15 minutes early",
                "Bring insurance card",
                "Fast for 8 hours if blood work needed",
                "Bring list of current medications"
            ]
        };
        
        report {
            "success": True,
            "confirmation": confirmation,
            "message": "Appointment scheduled successfully"
        };
    }
}

# DATA MANAGEMENT
walker seed_initial_data {
    can seed with root entry {
        # Define user data as list of map literals (Jac dictionaries)
        users_data = [
            {
                "username": "sarah_j",
                "email": "sarah@example.com",
                "password": "password123",
                "full_name": "Sarah Johnson",
                "user_type": "patient",
                "age": 28,
                "week": 24,
                "blood_type": "A+",
                "phone": "+254712345678",
                "risk": "Low"
            },
            {
                "username": "dr_williams",
                "email": "drwilliams@example.com",
                "password": "doctor123",
                "full_name": "Dr. Jane Williams",
                "user_type": "doctor",
                "age": 45,
                "week": 0,
                "blood_type": "",
                "phone": "+254722334455",
                "risk": ""
            },
            {
                "username": "grace_m",
                "email": "grace@example.com",
                "password": "password123",
                "full_name": "Grace Mwangi",
                "user_type": "patient",
                "age": 32,
                "week": 32,
                "blood_type": "O-",
                "phone": "+254723456789",
                "risk": "Medium"
            }
        ];

        # Iterate over user data
        for u_data in users_data {
            # Check user type and create nodes accordingly
            if u_data["user_type"] == "patient" {
                root ++> Patient(
                    username=u_data["username"],
                    email=u_data["email"],
                    password_hash="hashed_" + u_data["password"],
                    full_name=u_data["full_name"],
                    user_type=u_data["user_type"],
                    age=u_data["age"],
                    pregnancy_week=u_data["week"],
                    blood_type=u_data["blood_type"],
                    phone=u_data["phone"],
                    risk_level=u_data["risk"],
                    created_at="2024-01-01",
                    last_login="Today"
                );
            } else {
                root ++> User(
                    username=u_data["username"],
                    email=u_data["email"],
                    password_hash="hashed_" + u_data["password"],
                    full_name=u_data["full_name"],
                    user_type=u_data["user_type"],
                    created_at="2024-01-01",
                    last_login="Today"
                );
            }
        }

        # Define health facilities data
        facilities_data = [
            {
                "name": "Kenyatta National Hospital",
                "type": "Hospital",
                "lat": -1.3041,
                "lng": 36.8073,
                "address": "Hospital Road, Nairobi",
                "phone": "+254-20-2726300",
                "services": ["Emergency", "Delivery", "Surgery", "ICU", "Lab", "Ultrasound"],
                "rating": 4.7,
                "image": "hospital1.jpg"
            },
            {
                "name": "Mama Lucy Hospital",
                "type": "Maternity Hospital",
                "lat": -1.3158,
                "lng": 36.8854,
                "address": "Mama Lucy Kibaki Road, Nairobi",
                "phone": "+254-709-106000",
                "services": ["Emergency", "Delivery", "Maternity", "Pediatrics", "Vaccination"],
                "rating": 4.5,
                "image": "hospital2.jpg"
            },
            {
                "name": "Nairobi Women's Hospital",
                "type": "Specialty Hospital",
                "lat": -1.2659,
                "lng": 36.8154,
                "address": "Hurlingham, Nairobi",
                "phone": "+254-732-222000",
                "services": ["Gynecology", "Maternity", "Fertility", "Ultrasound", "Surgery"],
                "rating": 4.8,
                "image": "hospital3.jpg"
            }
        ];

        # Create HealthFacility nodes
        for f_data in facilities_data {
            root ++> HealthFacility(
                name=f_data["name"],
                facility_type=f_data["type"],
                location_lat=f_data["lat"],
                location_lng=f_data["lng"],
                address=f_data["address"],
                phone=f_data["phone"],
                services=f_data["services"],
                rating=f_data["rating"],
                image_url=f_data["image"]
            );
        }

        # Define care tips
        care_tips = [
            {
                "title": "Prenatal Nutrition Guide",
                "content": "Ensure adequate intake of folic acid, iron, calcium, and protein. Include leafy greens, lean meats, dairy, and whole grains in your diet.",
                "trimester": 1,
                "category": "Nutrition",
                "icon": "fas fa-apple-alt",
                "image": "nutrition.jpg"
            },
            {
                "title": "Exercise During Pregnancy",
                "content": "Moderate exercise like walking, swimming, or prenatal yoga for 30 minutes daily can improve mood, sleep, and reduce pregnancy discomfort.",
                "trimester": 2,
                "category": "Exercise",
                "icon": "fas fa-walking",
                "image": "exercise.jpg"
            },
            {
                "title": "Preparing for Labor",
                "content": "Learn breathing techniques, pack your hospital bag by week 36, know signs of labor, and have emergency contacts ready.",
                "trimester": 3,
                "category": "Preparation",
                "icon": "fas fa-baby-carriage",
                "image": "labor.jpg"
            }
        ];

        # Create CareTip nodes
        for tip in care_tips {
            root ++> CareTip(
                title=tip["title"],
                content=tip["content"],
                trimester=tip["trimester"],
                category=tip["category"],
                icon=tip["icon"],
                image_url=tip["image"],
                created_at="2024-01-01"
            );
        }

        report {"status": "data_seeded", "users": 3, "facilities": 3, "tips": 3};
    }
}

#dashboard walker 
walker get_dashboard_data {
    has user_id: str = "";

    can fetch_data with root entry {
        # Get User nodes connected from root
        user_nodes = [-->](`?User);

        # Find user node by id
        user_node = None;
        for u in user_nodes {
            if u.id == self.user_id {
                user_node = u;
                break;
            }
        }

        if not user_node {
            report {"error": "User not found"};
            disengage;
        }

        # Check if user is patient and handle patient dashboard
        if user_node.user_type == "patient" {
            # Find Patient nodes connected from root
            patient_nodes = [-->](`?Patient);
            patient_node = None;
            for p in patient_nodes {
                if p.id == self.user_id {
                    patient_node = p;
                    break;
                }
            }

            if not patient_node {
                report {"error": "Patient node not found"};
                disengage;
            }

            # Prepare patient data
            patient_data = {
                "name": patient_node.full_name,
                "age": patient_node.age,
                "week": patient_node.pregnancy_week,
                "blood_type": patient_node.blood_type,
                "risk_level": patient_node.risk_level,
                "phone": patient_node.phone,
                "emergency_contact": patient_node.emergency_contact
            };

            # Get health metrics related to patient
            metrics = [patient_node -->](`?HealthMetric);
            metric_list = [];
            abnormal_count = 0;

            for m in metrics {
                metric_list.append({
                    "type": m.metric_type,
                    "value": m.value,
                    "unit": m.unit,
                    "timestamp": m.timestamp,
                    "is_abnormal": m.is_abnormal
                });
                if m.is_abnormal {
                    abnormal_count += 1;
                }
            }

            # Get risk reports related to patient
            risks = [patient_node -->](`?RiskReport);
            risk_list = [];
            high_risk_count = 0;

            for r in risks {
                risk_list.append({
                    "summary": r.summary,
                    "severity": r.severity,
                    "recommendation": r.recommendation,
                    "detected_at": r.detected_at
                });
                if r.severity == "High" or r.severity == "Critical" {
                    high_risk_count += 1;
                }
            }

            # Get appointments related to patient
            appointments = [patient_node -->](`?Appointment);
            appointment_list = [];
            upcoming_appointments_count = 0;

            for a in appointments {
                appointment_list.append({
                    "doctor": a.doctor_name,
                    "date": a.appointment_date,
                    "purpose": a.purpose,
                    "status": a.status,
                    "location": a.location
                });
                if a.status == "Scheduled" {
                    upcoming_appointments_count += 1;
                }
            }

            # Calculate stats
            stats = {
                "total_metrics": len(metrics),
                "abnormal_metrics": abnormal_count,
                "total_appointments": len(appointments),
                "upcoming_appointments": upcoming_appointments_count,
                "high_risk_alerts": high_risk_count
            };

            report {
                "user_type": "patient",
                "patient": patient_data,
                "metrics": metric_list,
                "risks": risk_list,
                "appointments": appointment_list,
                "stats": stats
            };
            disengage;
        }

        # Doctor/Admin dashboard
        all_patients = [-->](`?Patient);
        patient_count = len(all_patients);

        alerts = [-->](`?EmergencyAlert);
        active_alerts = 0;
        for a in alerts {
            if a.status == "Active" {
                active_alerts += 1;
            }
        }

        report {
            "user_type": user_node.user_type,
            "patient_count": patient_count,
            "active_alerts": active_alerts,
            "total_appointments": 0,
            "today_visits": 0
        };
    }
}

walker get_care_tips {
    has trimester: int = 0;

    can fetch_tips with root entry {
        tips = [];
        all_tips = [-->](`?CareTip);

        for tip in all_tips {
            if self.trimester == 0 or tip.trimester == self.trimester {
                tips.append({
                    "id": tip.id,
                    "title": tip.title,
                    "content": tip.content,
                    "trimester": tip.trimester,
                    "category": tip.category,
                    "icon": tip.icon,
                    "image_url": tip.image_url
                });
            }
        }

        report {"success": True, "tips": tips};
    }
}

walker get_facilities {
    has lat: float = -1.286389;
    has lng: float = 36.817223;
    has max_distance_km: float = 50.0;
    
    can fetch_facilities with root entry {
        facilities = [];
        all_facilities = [-->](`?HealthFacility);
        
        for facility in all_facilities {
            # Calculate distance (simplified)
            lat_diff = self.lat - facility.location_lat;
            lng_diff = self.lng - facility.location_lng;
            distance = ((lat_diff ** 2) + (lng_diff ** 2)) ** 0.5 * 111.0;
            
            if distance <= self.max_distance_km {
                facilities.append({
                    "id": facility.id,
                    "name": facility.name,
                    "type": facility.facility_type,
                    "lat": facility.location_lat,
                    "lng": facility.location_lng,
                    "address": facility.address,
                    "phone": facility.phone,
                    "services": facility.services,
                    "distance": distance,
                    "rating": facility.rating,
                    "image_url": facility.image_url
                });
            }
        }
        
        # Sort by distance
        sorted_facilities = [];
        for f in facilities {
            inserted = False;
            for i in range(0, len(sorted_facilities)) {
                if f["distance"] < sorted_facilities[i]["distance"] {
                    sorted_facilities.insert(i, f);
                    inserted = True;
                    break;
                }
            }
            if not inserted {
                sorted_facilities.append(f);
            }
        }
        
        report {"success": True, "facilities": sorted_facilities};
    }
}

# HELPER WALKERS
walker get_node_by_id {
    has node_id: str;
    
    can find_node with root entry {
        # Simplified node lookup
        all_nodes = [-->];
        for node in all_nodes {
            if str(node.id) == self.node_id or node.username == self.node_id or node.email == self.node_id {
                report {"node": node};
                disengage;
            }
        }
        report {"node": None};
    }
}

# ==================== 3. INTEGRATED FRONTEND (cl) ====================

cl {
    import from react { useState, useEffect }
    import from "@jac-client/utils" {
        Router,
        Routes,
        Route,
        Link,
        Navigate,
        useNavigate,
        jacCall,
        jacLogin,
        jacSignup,
        jacLogout,
        jacIsLoggedIn
    }
    
    # ===== GLOBAL STYLES =====
    
    def GlobalStyles() -> str {
        return """
            <style>
                /* Dark Pink Theme */
                :root {
                    --primary-color: #d81b60;
                    --primary-dark: #ad1457;
                    --primary-light: #f48fb1;
                    --primary-gradient: linear-gradient(135deg, #d81b60 0%, #ad1457 100%);
                    --secondary-color: #8e24aa;
                    --accent-color: #ff4081;
                    --text-dark: #2c3e50;
                    --text-light: #6c757d;
                    --text-white: #ffffff;
                    --bg-light: #f8f9fa;
                    --bg-white: #ffffff;
                    --border-color: #e9ecef;
                    --success-color: #4caf50;
                    --warning-color: #ff9800;
                    --danger-color: #f44336;
                    --info-color: #2196f3;
                    --shadow-sm: 0 2px 4px rgba(0,0,0,0.05);
                    --shadow-md: 0 4px 6px rgba(0,0,0,0.07);
                    --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
                    --radius-sm: 6px;
                    --radius-md: 10px;
                    --radius-lg: 16px;
                }
                
                * { margin: 0; padding: 0; box-sizing: border-box; }
                
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    background-color: var(--bg-light);
                    color: var(--text-dark);
                    line-height: 1.6;
                }
                
                .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 0 20px;
                }
                
                /* Buttons */
                .btn {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    padding: 10px 20px;
                    border: none;
                    border-radius: var(--radius-md);
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    gap: 8px;
                }
                
                .btn-primary {
                    background: var(--primary-gradient);
                    color: var(--text-white);
                }
                
                .btn-primary:hover {
                    transform: translateY(-2px);
                    box-shadow: var(--shadow-lg);
                }
                
                .btn-outline {
                    background: transparent;
                    border: 2px solid var(--primary-color);
                    color: var(--primary-color);
                }
                
                .btn-outline:hover {
                    background: var(--primary-color);
                    color: var(--text-white);
                }
                
                /* Cards */
                .card {
                    background: var(--bg-white);
                    border-radius: var(--radius-md);
                    box-shadow: var(--shadow-md);
                    padding: 24px;
                    margin-bottom: 24px;
                    border: 1px solid var(--border-color);
                }
                
                /* Alerts */
                .alert {
                    padding: 16px 20px;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                    display: flex;
                    align-items: center;
                    gap: 12px;
                }
                
                .alert-success {
                    background: #d4edda;
                    color: #155724;
                    border-left: 4px solid var(--success-color);
                }
                
                .alert-danger {
                    background: #f8d7da;
                    color: #721c24;
                    border-left: 4px solid var(--danger-color);
                }
                
                .alert-info {
                    background: #d1ecf1;
                    color: #0c5460;
                    border-left: 4px solid var(--info-color);
                }
                
                /* Forms */
                .form-group { margin-bottom: 20px; }
                
                .form-label {
                    display: block;
                    margin-bottom: 8px;
                    font-weight: 500;
                }
                
                .form-control {
                    width: 100%;
                    padding: 12px 16px;
                    border: 1px solid var(--border-color);
                    border-radius: var(--radius-md);
                    font-size: 14px;
                }
                
                .form-control:focus {
                    outline: none;
                    border-color: var(--primary-color);
                    box-shadow: 0 0 0 3px rgba(216, 27, 96, 0.1);
                }
                
                /* Utility */
                .text-center { text-align: center; }
                .text-primary { color: var(--primary-color); }
                .mb-2 { margin-bottom: 16px; }
                .mb-3 { margin-bottom: 24px; }
                .mt-3 { margin-top: 24px; }
                .d-flex { display: flex; }
                .align-center { align-items: center; }
                .justify-center { justify-content: center; }
                .gap-2 { gap: 16px; }
                .w-100 { width: 100%; }
                
                /* Spinner */
                .spinner {
                    width: 40px;
                    height: 40px;
                    border: 3px solid rgba(216, 27, 96, 0.1);
                    border-radius: 50%;
                    border-top-color: var(--primary-color);
                    animation: spin 1s ease-in-out infinite;
                    margin: 0 auto;
                }
                
                @keyframes spin {
                    to { transform: rotate(360deg); }
                }
            </style>
        """;
    }
    
    # ===== AUTHENTICATION =====
     def useAuth() -> dict {
    let [user, setUser] = useState(None);
    let [loading, setLoading] = useState(True);

    # Define checkAuth helper
    def checkAuth() -> None {
        userStr = localStorage.getItem("maternai_user");
       
        if userStr {
            # In Jac client, we can just use try-catch directly
            userData = JSON.parse(userStr);
            if userData {
                setUser(userData);
            } else {
                localStorage.removeItem("maternai_user");
                setUser(None);
            }
        }
        setLoading(False);
    }

    # Effect to run checkAuth on mount
    useEffect(lambda -> None {
        checkAuth();
    }, []);

    # Async Login function
    async def login(email: str, password: str) -> bool {
        response = await fetch("/api/login", {
            "method": "POST",
            "headers": {
                "Content-Type": "application/json"
            },
            "body": JSON.stringify({"email": email, "password": password})
        });

        if response.ok {
            data = await response.json();
            localStorage.setItem("maternai_user", JSON.stringify(data.user));
            setUser(data.user);
            return True;
        }
        return False;
    }

    # Logout function
    def logout() -> None {
        localStorage.removeItem("maternai_user");
        setUser(None);
        window.location.href = "/login";
    }

    # Return the auth object
    return {
        "user": user,
        "loading": loading,
        "login": login,
        "logout": logout,
        "isLoggedIn": user != None
    };
}

# Protected Component
def ProtectedComponent() -> any {
    auth = useAuth();

    if auth["loading"] {
        return <div>Loading...</div>;
    }

    if not auth["isLoggedIn"] {
        return <div>Please login</div>;
    }

    return <div>
        <h1>Welcome, {auth["user"]["name"]}</h1>
        <button onClick={auth["logout"]}>Logout</button>
    </div>;
}

# Main App
def app() -> any {
    return <ProtectedComponent />;
}

    # ===== PAGES =====
    def LoginPage() -> any {
        let [email, setEmail] = useState("");
        let [password, setPassword] = useState("");
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(False);

        navigate = useNavigate();

        async def handleLogin(e: any) -> None {
            e.preventDefault();
            setError("");
            setLoading(True);

            result = await jacCall("login_user", {
                "email": email,
                "password": password
            });

            if result and result["success"] {
                localStorage.setItem("maternai_user", JSON.stringify(result["user"]));
                navigate("/dashboard");
            } elif result {
                setError(result["error"]);
            } else {
                setError("Login failed. Please try again.");
            }

            setLoading(False);
        }

        def handleEmailChange(e: any) -> None {
            setEmail(e.target.value);
        }

        def handlePasswordChange(e: any) -> None {
            setPassword(e.target.value);
        }

        return <div style={{"minHeight": "100vh", "display": "flex", "alignItems": "center", "justifyContent": "center", "background": "var(--bg-light)"}}>
            <div className="card" style={{"maxWidth": "400px", "width": "100%"}}>
                <div className="text-center mb-3">
                    <div style={{"width": "60px", "height": "60px", "margin": "0 auto 16px auto", "background": "var(--primary-gradient)", "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", "color": "white", "fontSize": "24px"}}>
                        <i className="fas fa-heartbeat"></i>
                    </div>
                    <h2>Welcome to MaternAI</h2>
                    <p style={{"color": "var(--text-light)"}}>Sign in to your account</p>
                </div>

                {error != "" and <div className="alert alert-danger">{error}</div>}

                <form onSubmit={handleLogin}>
                    <div className="form-group">
                        <label className="form-label">Email</label>
                        <input 
                            type="email" 
                            className="form-control" 
                            value={email} 
                            onChange={handleEmailChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={password} 
                            onChange={handlePasswordChange} 
                            required 
                        />
                    </div>

                    <button type="submit" className="btn btn-primary w-100" disabled={loading}>
                        {loading and <div className="spinner" style={{"width": "20px", "height": "20px"}}></div>}
                        {loading and "Signing In..." or "Sign In"}
                    </button>
                </form>

                <div className="text-center mt-3">
                    <p style={{"color": "var(--text-light)"}}>
                        Don't have an account? <Link to="/register" style={{"color": "var(--primary-color)"}}>Register</Link>
                    </p>
                </div>
            </div>
        </div>;
    }
    
     def RegisterPage() -> any {
        let [form, setForm] = useState({
            "full_name": "", 
            "email": "", 
            "password": "", 
            "confirm_password": "",
            "user_type": "patient", 
            "age": "", 
            "pregnancy_week": ""
        });
        let [error, setError] = useState("");
        let [success, setSuccess] = useState("");
        let [loading, setLoading] = useState(False);

        navigate = useNavigate();

        def updateForm(field: str, value: any) -> None {
            newForm = {
                "full_name": form["full_name"],
                "email": form["email"],
                "password": form["password"],
                "confirm_password": form["confirm_password"],
                "user_type": form["user_type"],
                "age": form["age"],
                "pregnancy_week": form["pregnancy_week"]
            };
            newForm[field] = value;
            setForm(newForm);
            setError("");
        }

        def redirectToLogin() -> None {
            navigate("/login");
        }

        async def handleRegister(e: any) -> None {
            e.preventDefault();
            setError("");

            if form["password"] != form["confirm_password"] {
                setError("Passwords do not match");
                return;
            }

            setLoading(True);

            result = await jacCall("register_user", {
                "username": form["email"].split("@")[0],
                "email": form["email"],
                "password": form["password"],
                "full_name": form["full_name"],
                "user_type": form["user_type"],
                "age": int(form["age"]) if form["age"] != "" else 0,
                "pregnancy_week": int(form["pregnancy_week"]) if form["pregnancy_week"] != "" else 0
            });

            if result and result["success"] {
                setSuccess("Registration successful! Redirecting to login...");
                setTimeout(redirectToLogin, 2000);
            } elif result {
                setError(result["error"]);
            } else {
                setError("Registration failed");
            }

            setLoading(False);
        }

        def handleFullNameChange(e: any) -> None {
            updateForm("full_name", e.target.value);
        }

        def handleEmailChange(e: any) -> None {
            updateForm("email", e.target.value);
        }

        def handlePasswordChange(e: any) -> None {
            updateForm("password", e.target.value);
        }

        def handleConfirmPasswordChange(e: any) -> None {
            updateForm("confirm_password", e.target.value);
        }

        def handleUserTypeChange(e: any) -> None {
            updateForm("user_type", e.target.value);
        }

        def handleAgeChange(e: any) -> None {
            updateForm("age", e.target.value);
        }

        def handlePregnancyWeekChange(e: any) -> None {
            updateForm("pregnancy_week", e.target.value);
        }

        return <div style={{"minHeight": "100vh", "display": "flex", "alignItems": "center", "justifyContent": "center", "background": "var(--bg-light)"}}>
            <div className="card" style={{"maxWidth": "500px", "width": "100%"}}>
                <div className="text-center mb-3">
                    <div style={{"width": "60px", "height": "60px", "margin": "0 auto 16px auto", "background": "var(--primary-gradient)", "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", "color": "white", "fontSize": "24px"}}>
                        <i className="fas fa-user-plus"></i>
                    </div>
                    <h2>Create Account</h2>
                    <p style={{"color": "var(--text-light)"}}>Join MaternAI for personalized care</p>
                </div>

                {success != "" and <div className="alert alert-success">{success}</div>}
                {error != "" and <div className="alert alert-danger">{error}</div>}

                <form onSubmit={handleRegister}>
                    <div className="form-group">
                        <label className="form-label">Full Name</label>
                        <input 
                            type="text" 
                            className="form-control" 
                            value={form["full_name"]} 
                            onChange={handleFullNameChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Email</label>
                        <input 
                            type="email" 
                            className="form-control" 
                            value={form["email"]} 
                            onChange={handleEmailChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={form["password"]} 
                            onChange={handlePasswordChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Confirm Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={form["confirm_password"]} 
                            onChange={handleConfirmPasswordChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">User Type</label>
                        <select 
                            className="form-control" 
                            value={form["user_type"]} 
                            onChange={handleUserTypeChange}
                        >
                            <option value="patient">Expecting Mother</option>
                            <option value="doctor">Healthcare Provider</option>
                        </select>
                    </div>

                    {form["user_type"] == "patient" and 
                        <div>
                            <div className="form-group">
                                <label className="form-label">Age</label>
                                <input 
                                    type="number" 
                                    className="form-control" 
                                    value={form["age"]} 
                                    onChange={handleAgeChange} 
                                    required 
                                />
                            </div>

                            <div className="form-group">
                                <label className="form-label">Pregnancy Week</label>
                                <input 
                                    type="number" 
                                    className="form-control" 
                                    value={form["pregnancy_week"]} 
                                    onChange={handlePregnancyWeekChange} 
                                    required 
                                />
                            </div>
                        </div>
                    }

                    <button type="submit" className="btn btn-primary w-100" disabled={loading}>
                        {loading and <div className="spinner" style={{"width": "20px", "height": "20px"}}></div>}
                        {loading and "Creating Account..." or "Create Account"}
                    </button>
                </form>

                <div className="text-center mt-3">
                    <p style={{"color": "var(--text-light)"}}>
                        Already have an account? <Link to="/login" style={{"color": "var(--primary-color)"}}>Sign In</Link>
                    </p>
                </div>
            </div>
        </div>;
    }
}
    
    # ===== NAVBAR =====
    def NavBar() -> any {
        let [loggedIn, setLoggedIn] = useState(False);
        let [user, setUser] = useState(None);
        
        def handleLogout() -> None {
            localStorage.removeItem("maternai_user");
            window.location.href = "/login";
        }
        
        return <nav style={{"background": "var(--primary-gradient)", "padding": "16px 0", "boxShadow": "var(--shadow-md)"}}>
            <div className="container" style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center"}}>
                <Link to="/" style={{"textDecoration": "none", "display": "flex", "alignItems": "center", "gap": "12px", "color": "white"}}>
                    <i className="fas fa-baby" style={{"fontSize": "24px"}}></i>
                    <h1 style={{"margin": "0", "fontSize": "20px", "fontWeight": "700"}}>MaternAI</h1>
                </Link>
                
                <div style={{"display": "flex", "gap": "16px", "alignItems": "center"}}>
                    {loggedIn and
                        <div style={{"display": "flex", "gap": "16px", "alignItems": "center"}}>
                            <Link to="/dashboard" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Dashboard</Link>
                            <Link to="/facilities" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Hospitals</Link>
                            <Link to="/care-tips" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Care Tips</Link>
                            <div style={{"display": "flex", "alignItems": "center", "gap": "8px", "color": "white"}}>
                                <i className="fas fa-user"></i>
                                <span>{user and user["full_name"] or "User"}</span>
                            </div>
                            <button onClick={handleLogout} className="btn" style={{"background": "rgba(255,255,255,0.2)", "color": "white", "padding": "8px 16px"}}>
                                Logout
                            </button>
                        </div>
                    }
                    {not loggedIn and
                        <div style={{"display": "flex", "gap": "12px"}}>
                            <Link to="/login" className="btn" style={{"background": "rgba(255,255,255,0.2)", "color": "white"}}>Login</Link>
                            <Link to="/register" className="btn" style={{"background": "white", "color": "var(--primary-color)"}}>Register</Link>
                        </div>
                    }
                </div>
            </div>
        </nav>;
    }

    # ===== DASHBOARD =====
    # Helper function to call the backend walker
    def jacCall(walker_name, payload) {
        # This is a mock implementation. In a real Jac app, this is handled by the framework.
        print("MOCK: Calling jacCall", walker_name, payload);
        # Return mock data for testing purposes
        return {
            "user_type": "patient",
            "patient": {
                "name": "Jane Doe",
                "age": 30,
                "week": 28,
                "blood_type": "A+",
                "risk_level": "Medium"
            },
            "stats": {
                "total_metrics": 45,
                "abnormal_metrics": 3,
                "upcoming_appointments": 2
            },
            "appointments": [
                {"id": 1, "doctor": "Dr. Smith", "date": "2025-01-15", "purpose": "Checkup", "status": "Scheduled", "location": "Clinic A"},
                {"id": 2, "doctor": "Dr. Jones", "date": "2025-01-22", "purpose": "Ultrasound", "status": "Scheduled", "location": "Imaging Center"}
            ]
        };
    }

    def DashboardPage() {
        # Using null and true/false for JS compatibility
        let [user, setUser] = useState(null);
        let [data, setData] = useState(null);
        let [loading, setLoading] = useState(true);
        
        # Check authentication on mount
        def checkAuth() {
            userStr = localStorage.getItem("maternai_user");
            if userStr {
                try {
                    userData = JSON.parse(userStr);
                    setUser(userData);
                } catch(e) {
                    localStorage.removeItem("maternai_user");
                    setUser(null);
                }
            }
        }
        
        useEffect(lambda { checkAuth(); }, []);
        
        async def loadData() {
            if user == null {
                return;
            }
            
            setLoading(true);
            
            # Using bracket notation for user data access for robustness
            result = await jacCall("get_dashboard_data", {
                "user_id": user["id"]
            });
            
            if result {
                setData(result);
            }
            setLoading(false);
        }
        
        def loadDataEffect() {
            if user != null {
                loadData();
            }
        }
        
        useEffect(lambda { loadDataEffect(); }, [user]);
        
        # --- Rendering Logic ---
        
        # Redirect if not logged in
        if user == null {
            return <Navigate to="/login" />;
        }
        
        if loading {
            return <div className="container" style={{"padding": "40px 20px", "textAlign": "center"}}>
                <div className="spinner"></div>
                <p style={{"marginTop": "16px", "color": "var(--text-light)"}}>Loading dashboard...</p>
            </div>;
        }
        
        if data == null {
            return <div className="container" style={{"padding": "40px 20px"}}>
                <div className="alert alert-danger">Failed to load dashboard data</div>
            </div>;
        }
        
        # Use bracket notation and safer defaults
        patient = data["patient"] or {};
        stats = data["stats"] or {};
        appointments = data["appointments"] or [];
        
        return <div>
            <div className="container" style={{"padding": "32px 20px"}}>
                <div className="card" style={{"display": "flex", "alignItems": "center", "gap": "24px", "padding": "24px"}}>
                    <div style={{"width": "80px", "height": "80px", "borderRadius": "50%", "background": "var(--primary-gradient)", 
                                 "display": "flex", "alignItems": "center", "justifyContent": "center", "color": "white", "fontSize": "32px", "fontWeight": "600"}}>
                        {patient["name"] and patient["name"][0] or "P"}
                    </div>
                    <div style={{"flex": "1"}}>
                        <h2 style={{"margin": "0 0 8px 0", "fontSize": "24px"}}>
                            {patient["name"] or "Patient"}
                        </h2>
                        <div style={{"display": "flex", "gap": "24px", "color": "var(--text-light)", "fontSize": "14px"}}>
                            <span><i className="fas fa-user"></i> Age: {patient["age"] or 0}</span>
                            <span><i className="fas fa-calendar-alt"></i> Week: {patient["week"] or 0}/40</span>
                            <span><i className="fas fa-tint"></i> Blood: {patient["blood_type"] or "N/A"}</span>
                        </div>
                    </div>
                    <button onClick={loadData} className="btn btn-outline">
                        <i className="fas fa-sync-alt"></i> Refresh
                    </button>
                </div>
                
                <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(200px, 1fr))", "gap": "16px", "margin": "24px 0"}}>
                    <div className="card" style={{"textAlign": "center", "padding": "20px"}}>
                        <h3 style={{"fontSize": "32px", "color": "var(--primary-color)", "margin": "0 0 8px 0"}}>
                            {stats["total_metrics"] or 0}
                        </h3>
                        <p style={{"color": "var(--text-light)", "margin": "0"}}>Health Metrics</p>
                    </div>
                    
                    <div className="card" style={{"textAlign": "center", "padding": "20px"}}>
                        <h3 style={{"fontSize": "32px", "color": "var(--primary-color)", "margin": "0 0 8px 0"}}>
                            {stats["abnormal_metrics"] or 0}
                        </h3>
                        <p style={{"color": "var(--text-light)", "margin": "0"}}>Abnormal Readings</p>
                    </div>
                    
                    <div className="card" style={{"textAlign": "center", "padding": "20px"}}>
                        <h3 style={{"fontSize": "32px", "color": "var(--secondary-color)", "margin": "0 0 8px 0"}}>
                            {stats["upcoming_appointments"] or 0}
                        </h3>
                        <p style={{"color": "var(--text-light)", "margin": "0"}}>Upcoming Appointments</p>
                    </div>
                </div>
                
                <div className="card">
                    <h3 style={{"margin": "0 0 20px 0", "display": "flex", "alignItems": "center", "gap": "10px"}}>
                        <i className="fas fa-calendar-check" style={{"color": "var(--primary-color)"}}></i>
                        Upcoming Appointments
                    </h3>
                    
                    {len(appointments) == 0 and
                        <div style={{"textAlign": "center", "padding": "40px 20px", "color": "var(--text-light)"}}>
                            <i className="fas fa-calendar-plus" style={{"fontSize": "48px", "marginBottom": "16px", "opacity": "0.5"}}></i>
                            <p>No upcoming appointments</p>
                        </div>
                    }
                    {len(appointments) > 0 and
                        <div>
                            {appointments.map(lambda(apt) { # FIXED: Corrected callback function syntax
                                return <div key={apt["id"]} style={{"padding": "16px", "borderBottom": "1px solid var(--border-color)", 
                                                    "display": "flex", "alignItems": "center", "justifyContent": "space-between"}}>
                                    <div>
                                        <h4 style={{"margin": "0 0 4px 0"}}>{apt["doctor"]}</h4>
                                        <p style={{"color": "var(--text-light)", "margin": "0", "fontSize": "14px"}}>
                                            <i className="fas fa-calendar"></i> {apt["date"]} • {apt["purpose"]}
                                        </p>
                                    </div>
                                    <span style={{"color": apt["status"] == "Scheduled" and "#28a745" or "#f44336", "fontWeight": "500"}}>
                                        {apt["status"]}
                                    </span>
                                </div>;
                            })}
                        </div>
                    }
                </div>
            </div>
        </div>;
    }

    # Main App definition (required for running)
    def App() {
        return <div>
            <style>
                {`
                :root {
                    --primary-color: #007bff;
                    --secondary-color: #28a745;
                    --text-color: #333;
                    --text-light: #6c757d;
                    --background-color: #f8f9fa;
                    --border-color: #dee2e6;
                    --card-bg: #fff;
                    --primary-gradient: linear-gradient(45deg, #007bff, #0056b3);
                }
                body {
                    font-family: 'Inter', sans-serif;
                    background-color: var(--background-color);
                    margin: 0;
                    padding: 0;
                    color: var(--text-color);
                }
                .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 0 20px;
                }
                .card {
                    background-color: var(--card-bg);
                    border-radius: 8px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                    padding: 24px;
                    margin-bottom: 20px;
                }
                .btn {
                    padding: 10px 15px;
                    border-radius: 6px;
                    cursor: pointer;
                    font-weight: 500;
                    transition: background-color 0.2s, box-shadow 0.2s;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                }
                .btn-outline {
                    background-color: transparent;
                    border: 1px solid var(--primary-color);
                    color: var(--primary-color);
                }
                .btn-outline:hover {
                    background-color: rgba(0, 123, 255, 0.05);
                }
                .spinner {
                    border: 4px solid rgba(0, 0, 0, 0.1);
                    width: 36px;
                    height: 36px;
                    border-radius: 50%;
                    border-left-color: var(--primary-color);
                    animation: spin 1s ease infinite;
                    margin: 0 auto;
                }
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
                `}
            </style>
            <DashboardPage />
        </div>;
    }


    # ===== FACILITIES PAGE =====
    
    def FacilitiesPage() -> any {
        let [facilities, setFacilities] = useState([]);
        let [loading, setLoading] = useState(True);
        
        user = getCurrentUser();
        
        async def loadFacilities() -> None {
            setLoading(True);
            try {
                lat = user ? user.get("location_lat", -1.286389) : -1.286389;
                lng = user ? user.get("location_lng", 36.817223) : 36.817223;
                
                result = await jacCall("get_facilities", {
                    "lat": lat,
                    "lng": lng
                });
                
                if result["success"]:
                    setFacilities(result["facilities"]);
            } catch (error) {
                console.error("Error loading facilities:", error);
            } finally {
                setLoading(False);
            }
        }
        
        useEffect(lambda -> None { loadFacilities(); }, []);
        
        return <div>
            {GlobalStyles()}
            <div class="container" style={{"padding": "32px 20px"}}>
                <h1 style={{"marginBottom": "24px"}}>Healthcare Facilities</h1>
                
                {loading ? 
                    <div style={{"textAlign": "center", "padding": "40px 20px"}}>
                        <div class="spinner"></div>
                        <p style={{"marginTop": "16px", "color": "var(--text-light)"}}>Loading facilities...</p>
                    </div>
                :
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fill, minmax(300px, 1fr))", "gap": "24px"}}>
                        {facilities.map(lambda facility: any -> any {
                            return <div class="card" key={facility["id"]}>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "12px", "marginBottom": "16px"}}>
                                    <div style={{"width": "48px", "height": "48px", "background": "var(--primary-color)", "borderRadius": "8px", 
                                              "display": "flex", "alignItems": "center", "justifyContent": "center", "color": "white", "fontSize": "20px"}}>
                                        <i class="fas fa-hospital"></i>
                                    </div>
                                    <div>
                                        <h3 style={{"margin": "0 0 4px 0"}}>{facility["name"]}</h3>
                                        <p style={{"color": "var(--text-light)", "margin": "0", "fontSize": "14px"}}>{facility["type"]}</p>
                                    </div>
                                </div>
                                
                                <p style={{"color": "var(--text-light)", "fontSize": "14px", "marginBottom": "12px"}}>
                                    <i class="fas fa-map-marker-alt"></i> {facility["address"]}
                                </p>
                                
                                <div style={{"display": "flex", "justifyContent": "space-between", "marginBottom": "16px"}}>
                                    <div>
                                        <p style={{"fontSize": "12px", "color": "var(--text-light)", "marginBottom": "4px"}}>Distance</p>
                                        <p style={{"fontSize": "16px", "fontWeight": "600"}}>{facility["distance"].toFixed(1)} km</p>
                                    </div>
                                    <div>
                                        <p style={{"fontSize": "12px", "color": "var(--text-light)", "marginBottom": "4px"}}>Rating</p>
                                        <p style={{"fontSize": "16px", "fontWeight": "600", "color": "#ffc107"}}>
                                            <i class="fas fa-star"></i> {facility["rating"]}
                                        </p>
                                    </div>
                                </div>
                                
                                <button class="btn btn-primary w-100">
                                    <i class="fas fa-phone"></i> Call {facility["phone"]}
                                </button>
                            </div>;
                        })}
                    </div>
                }
            </div>
        </div>;
    }
    
    # ===== CARE TIPS PAGE =====
    
    def CareTipsPage() -> any {
        let [tips, setTips] = useState([]);
        let [loading, setLoading] = useState(True);
        let [trimesterFilter, setTrimesterFilter] = useState(0);
        
        user = getCurrentUser();
        
        async def loadTips() -> None {
            setLoading(True);
            try {
                result = await jacCall("get_care_tips", {
                    "trimester": trimesterFilter
                });
                
                if result["success"]:
                    setTips(result["tips"]);
            } catch (error) {
                console.error("Error loading tips:", error);
            } finally {
                setLoading(False);
            }
        }
        
        useEffect(lambda -> None { loadTips(); }, [trimesterFilter]);
        
        return <div>
            {GlobalStyles()}
            <div class="container" style={{"padding": "32px 20px"}}>
                <h1 style={{"marginBottom": "24px"}}>Pregnancy Care Tips</h1>
                
                <div style={{"display": "flex", "gap": "12px", "marginBottom": "24px"}}>
                    <button onClick={lambda -> None { setTrimesterFilter(0); }} 
                            class="btn" style={{"background": trimesterFilter == 0 ? "var(--primary-color)" : "white", 
                                             "color": trimesterFilter == 0 ? "white" : "var(--text-dark)"}}>
                        All Tips
                    </button>
                    <button onClick={lambda -> None { setTrimesterFilter(1); }} 
                            class="btn" style={{"background": trimesterFilter == 1 ? "var(--primary-color)" : "white", 
                                             "color": trimesterFilter == 1 ? "white" : "var(--text-dark)"}}>
                        First Trimester
                    </button>
                    <button onClick={lambda -> None { setTrimesterFilter(2); }} 
                            class="btn" style={{"background": trimesterFilter == 2 ? "var(--primary-color)" : "white", 
                                             "color": trimesterFilter == 2 ? "white" : "var(--text-dark)"}}>
                        Second Trimester
                    </button>
                    <button onClick={lambda -> None { setTrimesterFilter(3); }} 
                            class="btn" style={{"background": trimesterFilter == 3 ? "var(--primary-color)" : "white", 
                                             "color": trimesterFilter == 3 ? "white" : "var(--text-dark)"}}>
                        Third Trimester
                    </button>
                </div>
                
                {loading ? 
                    <div style={{"textAlign": "center", "padding": "40px 20px"}}>
                        <div class="spinner"></div>
                        <p style={{"marginTop": "16px", "color": "var(--text-light)"}}>Loading tips...</p>
                    </div>
                :
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fill, minmax(300px, 1fr))", "gap": "24px"}}>
                        {tips.map(lambda tip: any -> any {
                            return <div class="card" key={tip["id"]}>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "12px", "marginBottom": "16px"}}>
                                    <div style={{"width": "40px", "height": "40px", "background": "var(--primary-color)15", "borderRadius": "8px", 
                                              "display": "flex", "alignItems": "center", "justifyContent": "center", "color": "var(--primary-color)", "fontSize": "16px"}}>
                                        <i class={tip["icon"]}></i>
                                    </div>
                                    <div>
                                        <h3 style={{"margin": "0 0 4px 0", "fontSize": "16px"}}>{tip["title"]}</h3>
                                        <p style={{"color": "var(--text-light)", "margin": "0", "fontSize": "12px"}}>
                                            Trimester {tip["trimester"]} • {tip["category"]}
                                        </p>
                                    </div>
                                </div>
                                
                                <p style={{"color": "var(--text-dark)", "fontSize": "14px", "lineHeight": "1.6"}}>
                                    {tip["content"]}
                                </p>
                            </div>;
                        })}
                    </div>
                }
            </div>
        </div>;
    }
    
    # ===== HOME PAGE =====
    
    def HomePage() -> any {
        loggedIn = isLoggedIn();
        
        return <div>
            {GlobalStyles()}
            {/* Hero Section */}
            <section style={{"background": "var(--primary-gradient)", "color": "white", "padding": "80px 0", "textAlign": "center"}}>
                <div class="container">
                    <h1 style={{"fontSize": "48px", "marginBottom": "24px", "fontWeight": "700"}}>MaternAI</h1>
                    <p style={{"fontSize": "20px", "marginBottom": "32px", "opacity": "0.9"}}>
                        AI-Powered Maternal Health Monitoring Platform
                    </p>
                    <div style={{"display": "flex", "gap": "16px", "justifyContent": "center"}}>
                        <Link to={loggedIn ? "/dashboard" : "/register"} class="btn" style={{"background": "white", "color": "var(--primary-color)", "padding": "16px 32px", "fontSize": "16px"}}>
                            {loggedIn ? "Go to Dashboard" : "Get Started"}
                        </Link>
                        <Link to="/care-tips" class="btn" style={{"background": "transparent", "border": "2px solid white", "color": "white", "padding": "16px 32px", "fontSize": "16px"}}>
                            View Care Tips
                        </Link>
                    </div>
                </div>
            </section>
            
            {/* Features */}
            <section style={{"padding": "80px 0"}}>
                <div class="container">
                    <h2 style={{"textAlign": "center", "marginBottom": "48px", "fontSize": "32px"}}>Our Features</h2>
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(250px, 1fr))", "gap": "32px"}}>
                        <div class="card" style={{"textAlign": "center"}}>
                            <div style={{"width": "60px", "height": "60px", "margin": "0 auto 20px auto", "background": "var(--primary-color)15", 
                                      "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", 
                                      "color": "var(--primary-color)", "fontSize": "24px"}}>
                                <i class="fas fa-heartbeat"></i>
                            </div>
                            <h3>Health Monitoring</h3>
                            <p style={{"color": "var(--text-light)"}}>Track vital signs and pregnancy metrics</p>
                        </div>
                        
                        <div class="card" style={{"textAlign": "center"}}>
                            <div style={{"width": "60px", "height": "60px", "margin": "0 auto 20px auto", "background": "var(--primary-color)15", 
                                      "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", 
                                      "color": "var(--primary-color)", "fontSize": "24px"}}>
                                <i class="fas fa-robot"></i>
                            </div>
                            <h3>AI Chat Assistant</h3>
                            <p style={{"color": "var(--text-light)"}}>24/7 AI-powered health advice</p>
                        </div>
                        
                        <div class="card" style={{"textAlign": "center"}}>
                            <div style={{"width": "60px", "height": "60px", "margin": "0 auto 20px auto", "background": "var(--primary-color)15", 
                                      "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", 
                                      "color": "var(--primary-color)", "fontSize": "24px"}}>
                                <i class="fas fa-hospital"></i>
                            </div>
                            <h3>Facility Finder</h3>
                            <p style={{"color": "var(--text-light)"}}>Locate nearby healthcare providers</p>
                        </div>
                        
                        <div class="card" style={{"textAlign": "center"}}>
                            <div style={{"width": "60px", "height": "60px", "margin": "0 auto 20px auto", "background": "var(--primary-color)15", 
                                      "borderRadius": "50%", "display": "flex", "alignItems": "center", "justifyContent": "center", 
                                      "color": "var(--primary-color)", "fontSize": "24px"}}>
                                <i class="fas fa-bell"></i>
                            </div>
                            <h3>Emergency Alert</h3>
                            <p style={{"color": "var(--text-light)"}}>Instant emergency response coordination</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>;
    }
    
    # ===== MAIN APP =====
    
    def App() -> any {
        return <div>
            <NavBar />
            <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/facilities" element={<FacilitiesPage />} />
                <Route path="/care-tips" element={<CareTipsPage />} />
                <Route path="*" element={<div class="container" style={{"padding": "40px 20px", "textAlign": "center"}}>
                    <h1>404 - Page Not Found</h1>
                    <Link to="/" class="btn btn-primary mt-3">Go Home</Link>
                </div>} />
            </Routes>
        </div>;
    }
    
    def app() -> any {
        return <Router>
            <App />
        </Router>;
    }
}

# ==================== 4. INITIALIZATION ====================

# Run this walker to seed data when needed
walker init {
    can init with root entry {
        # Seed initial data if no users exist
        users = [-->](?User);
        if len(users) == 0 {
            spawn here walker:seed_initial_data;
            report {"message": "Initial data seeded", "status": "success"};
        } else {
            report {"message": "Data already exists", "status": "skipped"};
        }
    }
}