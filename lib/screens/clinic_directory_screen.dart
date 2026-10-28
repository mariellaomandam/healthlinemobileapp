import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/healthline_firestore_service.dart';
import 'chat_detail.dart';

const _bg = Color(0xFF101010), _surface = Color(0xFF1C1A1A), _mauve = Color(0xFFB78A9B), _muted = Color(0xFFAAAAAA);

class ClinicDirectoryScreen extends StatelessWidget {
  final String service;
  const ClinicDirectoryScreen({super.key, this.service = 'Check-up'});

  @override
  Widget build(BuildContext context) {
    final api = HealthLineFirestoreService.instance;
    final stream = service == 'All clinics' ? api.publishedClinics() : api.publishedClinicsForService(service);
    return Scaffold(backgroundColor: _bg, appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, title: Text(service == 'All clinics' ? 'Clinics' : service)),
      body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream: stream, builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Could not load clinics: ${snap.error}', style: const TextStyle(color: Colors.redAccent)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No clinics have published ${service == 'All clinics' ? 'their profiles' : 'this service'} yet.', textAlign: TextAlign.center, style: const TextStyle(color: _muted))));
        return ListView.separated(padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_,__)=>const SizedBox(height:10), itemBuilder: (context,i) {
          final d=docs[i].data(); final services=List<String>.from(d['services'] ?? const []); final url=(d['imageUrl'] ?? '').toString();
          return Card(color:_surface, child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(backgroundColor:_mauve.withAlpha(50), backgroundImage:url.isNotEmpty?NetworkImage(url):null, child:url.isEmpty?const Icon(Icons.local_hospital_outlined,color:_mauve):null), title:Text((d['name']??'Clinic').toString(),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700)), subtitle:Padding(padding:const EdgeInsets.only(top:6),child:Text('${d['address']??'Address not provided'}\n${services.join(' • ')}',style:const TextStyle(color:_muted,height:1.4))), isThreeLine:true, trailing:const Icon(Icons.chevron_right,color:_mauve), onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ClinicDoctorsScreen(clinicId:docs[i].id,clinicName:(d['name']??'Clinic').toString()))));
        });
      }));
  }
}

class ClinicDoctorsScreen extends StatelessWidget {
  final String clinicId, clinicName;
  const ClinicDoctorsScreen({super.key,required this.clinicId,required this.clinicName});
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:_bg,appBar:AppBar(backgroundColor:_bg,foregroundColor:Colors.white,title:Text(clinicName)),body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:HealthLineFirestoreService.instance.db.collection('doctors').where('clinicId',isEqualTo:clinicId).where('active',isEqualTo:true).snapshots(),builder:(context,s){if(s.hasError)return Center(child:Text('Could not load doctors: ${s.error}',style:const TextStyle(color:Colors.redAccent)));if(!s.hasData)return const Center(child:CircularProgressIndicator());if(s.data!.docs.isEmpty)return const Center(child:Text('This clinic has not listed any doctors yet.',style:TextStyle(color:_muted)));return ListView(padding:const EdgeInsets.all(16),children:s.data!.docs.map((doc){final d=doc.data();final url=(d['imageUrl']??'').toString();return Card(color:_surface,child:ListTile(leading:CircleAvatar(backgroundColor:_mauve.withAlpha(40),backgroundImage:url.isNotEmpty?NetworkImage(url):null,child:url.isEmpty?const Icon(Icons.person_outline,color:_mauve):null),title:Text((d['name']??'Doctor').toString(),style:const TextStyle(color:Colors.white)),subtitle:Text('${d['specialty']??''}\n${d['bio']??''}',style:const TextStyle(color:_muted),maxLines:3,overflow:TextOverflow.ellipsis),isThreeLine:true,trailing:const Icon(Icons.chevron_right,color:_mauve),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>DoctorAvailabilityScreen(doctorId:doc.id,doctor:d,clinicId:clinicId,clinicName:clinicName))));}).toList());}));
}

class DoctorAvailabilityScreen extends StatelessWidget {
 final String doctorId,clinicId,clinicName; final Map<String,dynamic> doctor;
 const DoctorAvailabilityScreen({super.key,required this.doctorId,required this.doctor,required this.clinicId,required this.clinicName});
 @override Widget build(BuildContext context){final api=HealthLineFirestoreService.instance;return Scaffold(backgroundColor:_bg,appBar:AppBar(backgroundColor:_bg,foregroundColor:Colors.white,title:Text((doctor['name']??'Doctor').toString())),body:ListView(padding:const EdgeInsets.all(20),children:[Text((doctor['specialty']??'').toString(),style:const TextStyle(color:_mauve,fontSize:16)),const SizedBox(height:10),Text((doctor['bio']??'No biography provided.').toString(),style:const TextStyle(color:_muted,height:1.5)),const SizedBox(height:16),SizedBox(width:double.infinity,child:OutlinedButton.icon(onPressed:()async{try{final id=await api.getOrCreateConversation(clinicId);if(context.mounted)Navigator.push(context,MaterialPageRoute(builder:(_)=>ChatDetailScreen(hospital:clinicName,otherUid:clinicId,conversationId:id)));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Could not start message: $e')));}},icon:const Icon(Icons.chat_bubble_outline),label:const Text('Message clinic'),style:OutlinedButton.styleFrom(foregroundColor:_mauve)),),const SizedBox(height:24),const Text('Available appointment times',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:10),StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:api.availableSlots(doctorId),builder:(context,s){if(s.hasError)return Text('Could not load availability: ${s.error}',style:const TextStyle(color:Colors.redAccent));if(!s.hasData)return const Center(child:CircularProgressIndicator());final slots=s.data!.docs;if(slots.isEmpty)return const Text('No available times have been added yet.',style:TextStyle(color:_muted));return Column(children:slots.map((slot){final d=slot.data();final start=(d['startAt'] as Timestamp).toDate().toLocal();return Card(color:_surface,child:ListTile(title:Text('${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')} · ${TimeOfDay.fromDateTime(start).format(context)}',style:const TextStyle(color:Colors.white)),trailing:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:_mauve,foregroundColor:Colors.white),onPressed:()async{try{await api.requestAppointment(clinicId:clinicId,doctorId:doctorId,slotId:slot.id,startAt:start,clinicName:clinicName,doctorName:(doctor['name']??'Doctor').toString(),specialty:(doctor['specialty']??'').toString());if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Appointment requested.')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Could not book: $e')));}},child:const Text('Request'))));}).toList());})]));}
}
