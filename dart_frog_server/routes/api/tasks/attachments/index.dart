import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý tệp đính kèm của Task
///
/// Endpoint: /api/tasks/attachments
Future<Response> onRequest(RequestContext context) async {
  // Lấy DatabaseService từ middleware
  final db = context.read<DatabaseService>();
  
  // Xử lý các phương thức HTTP
  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy task_id từ query parameters
        final taskId = int.tryParse(
          context.request.uri.queryParameters['task_id'] ?? '',
        );
        
        if (taskId == null) {
          return Response.json(
            body: {'error': 'Thiếu task_id'},
            statusCode: HttpStatus.badRequest,
          );
        }
        
        // Lấy danh sách tệp đính kèm của task
        final attachments = await db.query(
          'SELECT * FROM attachments WHERE task_id = @taskId',
          {'taskId': taskId},
        );
        
        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonAttachments = JsonUtils.convertListToJson(attachments);
        return Response.json(body: jsonAttachments);
      } catch (e) {
        return Response.json(
          body: {'error': e.toString()},
          statusCode: HttpStatus.internalServerError,
        );
      }
    
    case HttpMethod.post:
      try {
        // Lấy dữ liệu từ request body
        final body = await context.request.json() as Map<String, dynamic>;
        
        // Kiểm tra dữ liệu đầu vào
        final taskId = body['task_id'] as int?;
        final attachmentId = body['attachment_id'] as int?;
        
        if (taskId == null || attachmentId == null) {
          return Response.json(
            body: {'error': 'Thiếu task_id hoặc attachment_id'},
            statusCode: HttpStatus.badRequest,
          );
        }
        
        // Liên kết tệp đính kèm với task
        final rowsAffected = await db.execute(
          'UPDATE attachments SET task_id = @taskId WHERE id = @id',
          {'id': attachmentId, 'taskId': taskId},
        );
        
        if (rowsAffected == 0) {
          return Response.json(
            body: {'error': 'Không tìm thấy tệp đính kèm'},
            statusCode: HttpStatus.notFound,
          );
        }
        
        // Lấy tệp đính kèm vừa liên kết
        final attachment = await db.queryOne(
          'SELECT * FROM attachments WHERE id = @id',
          {'id': attachmentId},
        );
        
        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonAttachment = JsonUtils.convertMapToJson(attachment!);
        
        return Response.json(
          body: jsonAttachment,
          statusCode: HttpStatus.ok,
        );
      } catch (e) {
        return Response.json(
          body: {'error': e.toString()},
          statusCode: HttpStatus.internalServerError,
        );
      }
    
    case HttpMethod.delete:
      try {
        // Lấy attachment_id từ query parameters
        final attachmentId = int.tryParse(
          context.request.uri.queryParameters['attachment_id'] ?? '',
        );
        
        if (attachmentId == null) {
          return Response.json(
            body: {'error': 'Thiếu attachment_id'},
            statusCode: HttpStatus.badRequest,
          );
        }
        
        // Hủy liên kết tệp đính kèm với task
        final rowsAffected = await db.execute(
          'UPDATE attachments SET task_id = NULL WHERE id = @id',
          {'id': attachmentId},
        );
        
        if (rowsAffected == 0) {
          return Response.json(
            body: {'error': 'Không tìm thấy tệp đính kèm'},
            statusCode: HttpStatus.notFound,
          );
        }
        
        return Response.json(
          body: {'success': true, 'message': 'Đã hủy liên kết tệp đính kèm'},
        );
      } catch (e) {
        return Response.json(
          body: {'error': e.toString()},
          statusCode: HttpStatus.internalServerError,
        );
      }
    
    default:
      return Response.json(
        body: {'error': 'Phương thức không được hỗ trợ'},
        statusCode: HttpStatus.methodNotAllowed,
      );
  }
}
